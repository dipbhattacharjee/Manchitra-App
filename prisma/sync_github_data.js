const fs = require('fs');
const path = require('path');

// Load environment variables from .env file if available
const envPath = path.join(__dirname, '..', '.env');
if (fs.existsSync(envPath)) {
  const envContent = fs.readFileSync(envPath, 'utf-8');
  envContent.split('\n').forEach((line) => {
    const parts = line.split('=');
    if (parts.length >= 2 && !line.trim().startsWith('#')) {
      const key = parts[0].trim();
      const val = parts.slice(1).join('=').trim().replace(/^["']|["']$/g, '');
      if (key && !process.env[key]) {
        process.env[key] = val;
      }
    }
  });
}

const GITHUB_JSON_URL = process.env.GITHUB_JSON_URL || 'https://raw.githubusercontent.com/dbaidya811/map_server/refs/heads/main/Must-visit.json';
const GITHUB_BASE_URL = process.env.GITHUB_BASE_URL || 'https://raw.githubusercontent.com/dbaidya811/map_server/refs/heads/main/';

const crypto = require('crypto');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const CLOUDINARY_CLOUD_NAME = process.env.CLOUDINARY_CLOUD_NAME;
const CLOUDINARY_API_KEY = process.env.CLOUDINARY_API_KEY;
const CLOUDINARY_API_SECRET = process.env.CLOUDINARY_API_SECRET;

/**
 * Upload an image URL to Cloudinary
 */
async function uploadToCloudinary(imageUrl, folder = 'map_server_pandals') {
  try {
    const timestamp = Math.floor(Date.now() / 1000).toString();
    const paramsToSign = `folder=${folder}&timestamp=${timestamp}${CLOUDINARY_API_SECRET}`;
    const signature = crypto.createHash('sha1').update(paramsToSign).digest('hex');

    const formData = new FormData();
    formData.append('file', imageUrl);
    formData.append('api_key', CLOUDINARY_API_KEY);
    formData.append('timestamp', timestamp);
    formData.append('signature', signature);
    formData.append('folder', folder);

    const res = await fetch(`https://api.cloudinary.com/v1_1/${CLOUDINARY_CLOUD_NAME}/image/upload`, {
      method: 'POST',
      body: formData,
    });

    if (!res.ok) {
      const errText = await res.text();
      console.error(`Failed to upload ${imageUrl}: ${res.status} ${errText}`);
      return null;
    }

    const data = await res.json();
    console.log(`Uploaded ${imageUrl} -> ${data.secure_url}`);
    return data.secure_url;
  } catch (e) {
    console.error(`Error uploading ${imageUrl}:`, e);
    return null;
  }
}

/**
 * Derive area from pandal name / description
 */
function deriveArea(name, description) {
  if (name.includes('Dum Dum')) return 'Dum Dum Park';
  if (name.includes('Hatibagan')) return 'Hatibagan';
  if (name.includes('Kumartuli')) return 'Kumartuli';
  if (name.includes('Kashi Bose')) return 'Shyambazar';
  if (name.includes('College Square')) return 'Central Kolkata';
  if (name.includes('Santosh Mitra')) return 'Bowbazar';
  if (name.includes('Ultadanga')) return 'Ultadanga';
  if (name.includes('Beliaghata') || name.includes('Beleghata')) return 'Beliaghata';
  if (name.includes('Sandhani')) return 'Beliaghata';
  if (name.includes('Ekdalia')) return 'Gariahat';
  if (name.includes('Singhi Park')) return 'Ballygunge';
  if (name.includes('Hindusthan Park')) return 'Gariahat';
  if (name.includes('Tridhara')) return 'Ballygunge';
  if (name.includes('Deshapriya')) return 'South Kolkata';
  if (name.includes('Maddox')) return 'Ballygunge';
  if (name.includes('Bhowanipur')) return 'Bhowanipur';
  if (name.includes('Chetla')) return 'Chetla';
  if (name.includes('Suruchi')) return 'New Alipore';
  if (name.includes('Mudiali')) return 'Tollygunge';
  if (name.includes('95 Pally')) return 'Jodhpur Park';
  if (name.includes('21 Pally')) return 'Ballygunge';
  if (name.includes('Rajdanga')) return 'Kasba';
  if (name.includes('Behala Nutan')) return 'Behala';
  if (name.includes('Buroshibtala')) return 'Behala';
  if (name.includes('Barisha')) return 'Barisha';
  if (name.includes('Ajeya')) return 'Haridevpur';
  if (name.includes('Naktala')) return 'Naktala';
  if (name.includes('Labony') || name.includes('EC Block')) return 'Salt Lake';
  return 'Kolkata';
}

async function run() {
  console.log('--- STARTING GITHUB TO CLOUDINARY & DATABASE SYNC ---');
  console.log('Fetching JSON from GitHub repo...');
  const response = await fetch(GITHUB_JSON_URL);
  if (!response.ok) {
    throw new Error(`Failed to fetch GitHub JSON: ${response.statusText}`);
  }
  const githubData = await response.json();
  console.log(`Fetched ${githubData.length} locations from GitHub.`);

  let count = 0;
  for (const item of githubData) {
    count++;
    console.log(`\n[${count}/${githubData.length}] Processing: ${item.name}`);

    // Upload local images to Cloudinary
    const cloudinaryUrls = [];
    if (item.local_images && item.local_images.length > 0) {
      for (const imgPath of item.local_images) {
        const fullGithubImgUrl = GITHUB_BASE_URL + imgPath;
        console.log(`Uploading image ${fullGithubImgUrl} to Cloudinary...`);
        const cUrl = await uploadToCloudinary(fullGithubImgUrl);
        if (cUrl) {
          cloudinaryUrls.push(cUrl);
        }
      }
    }

    const area = deriveArea(item.name, item.description || '');

    // Check if pandal exists by name
    const existing = await prisma.pandal.findFirst({
      where: { name: item.name },
    });

    let pandalRecord;
    if (existing) {
      console.log(`Updating existing pandal: ${existing.id} (${item.name})`);
      pandalRecord = await prisma.pandal.update({
        where: { id: existing.id },
        data: {
          area: area,
          description: item.description || existing.description,
          latitude: item.latitude || existing.latitude,
          longitude: item.longitude || existing.longitude,
          isFeatured2026: true,
        },
      });
    } else {
      console.log(`Creating new pandal: ${item.name}`);
      pandalRecord = await prisma.pandal.create({
        data: {
          name: item.name,
          area: area,
          committeeName: item.name,
          description: item.description || '',
          latitude: item.latitude,
          longitude: item.longitude,
          isFeatured2026: true,
          category: 'THEME_BASED',
          visitStartTime: '09:00',
          visitEndTime: '23:59',
          crowdLevel: 'HIGH',
        },
      });
    }

    // Now insert photos if we got Cloudinary URLs
    if (cloudinaryUrls.length > 0) {
      for (let i = 0; i < cloudinaryUrls.length; i++) {
        const photoUrl = cloudinaryUrls[i];
        // Check if photo exists
        const existingPhoto = await prisma.pandalPhoto.findFirst({
          where: { pandalId: pandalRecord.id, url: photoUrl },
        });

        if (!existingPhoto) {
          await prisma.pandalPhoto.create({
            data: {
              pandalId: pandalRecord.id,
              url: photoUrl,
              isCover: i === 0,
            },
          });
          console.log(`Saved photo in DB for ${item.name}: ${photoUrl}`);
        }
      }
    }
  }

  console.log('\n--- GITHUB TO CLOUDINARY & DB SYNC COMPLETED SUCCESSFULLY ---');
}

run().catch(console.error).finally(() => prisma.$disconnect());

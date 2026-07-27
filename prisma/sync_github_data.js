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

const GITHUB_REPO_CONTENTS_API = 'https://api.github.com/repos/dbaidya811/map_server/contents';
const GITHUB_BASE_URL = process.env.GITHUB_BASE_URL || 'https://raw.githubusercontent.com/dbaidya811/map_server/refs/heads/main/';
const KNOWN_CATEGORY_FILES = [
  'Alipore_Port_area.json',
  'Bidhannagar_s.json',
  'Central_Kolkata.json',
  'Must-visit.json',
  'North_Kolkata.json',
  'Northern_Suburb-Kolkata.json',
  'South_Kolkata.json',
  'Southern_Suburb_Kolkata.json'
];

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
  if (!CLOUDINARY_CLOUD_NAME || !CLOUDINARY_API_KEY || !CLOUDINARY_API_SECRET) {
    return null;
  }
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
 * Derive area from pandal name, description, and source filename
 */
function deriveArea(name, description, filename = '') {
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
  if (name.includes('Labony') || name.includes('EC Block') || name.includes('FD Block') || name.includes('BJ Block')) return 'Salt Lake';

  // Fallback to filename category
  if (filename.includes('Alipore')) return 'Alipore';
  if (filename.includes('Bidhannagar')) return 'Salt Lake';
  if (filename.includes('Central')) return 'Central Kolkata';
  if (filename.includes('North_Kolkata')) return 'North Kolkata';
  if (filename.includes('Northern_Suburb')) return 'Northern Suburbs';
  if (filename.includes('South_Kolkata')) return 'South Kolkata';
  if (filename.includes('Southern_Suburb')) return 'Southern Suburbs';

  return 'Kolkata';
}

/**
 * Fetch all JSON files from the GitHub repository contents
 */
async function getCategoryFiles() {
  try {
    const res = await fetch(GITHUB_REPO_CONTENTS_API, {
      headers: { 'User-Agent': 'FlutterAppSyncScript' }
    });
    if (res.ok) {
      const contents = await res.json();
      const jsonFiles = contents
        .filter(item => item.type === 'file' && item.name.endsWith('.json') && item.name !== 'package.json' && item.name !== 'package-lock.json')
        .map(item => item.name);
      if (jsonFiles.length > 0) {
        console.log(`Discovered ${jsonFiles.length} JSON files via GitHub API:`, jsonFiles);
        return jsonFiles;
      }
    }
  } catch (e) {
    console.warn('GitHub Repo Contents API failed, using known category files:', e.message);
  }
  return KNOWN_CATEGORY_FILES;
}

async function run() {
  console.log('--- STARTING GITHUB CATEGORIES TO CLOUDINARY & DATABASE SYNC ---');
  const files = await getCategoryFiles();

  const pandalsMap = new Map(); // Key: normalized pandal name

  for (const file of files) {
    const url = `${GITHUB_BASE_URL}${file}`;
    console.log(`Fetching category file: ${file} (${url})...`);
    try {
      const response = await fetch(url);
      if (!response.ok) {
        console.error(`Failed to fetch ${file}: status ${response.status}`);
        continue;
      }
      const items = await response.json();
      console.log(` -> ${items.length} items in ${file}`);

      for (const item of items) {
        if (!item.name) continue;
        const normKey = item.name.trim().toLowerCase();
        const existing = pandalsMap.get(normKey);

        if (!existing) {
          pandalsMap.set(normKey, {
            ...item,
            sourceFile: file,
            isMustVisit: file === 'Must-visit.json'
          });
        } else {
          // Merge images & take better description/must-visit status
          if (file === 'Must-visit.json') {
            existing.isMustVisit = true;
          }
          if (item.description && item.description.length > (existing.description || '').length) {
            existing.description = item.description;
          }
          if (item.local_images && item.local_images.length > 0) {
            const combined = new Set([...(existing.local_images || []), ...item.local_images]);
            existing.local_images = Array.from(combined);
          }
        }
      }
    } catch (e) {
      console.error(`Error processing file ${file}:`, e);
    }
  }

  const allPandals = Array.from(pandalsMap.values());
  console.log(`\n==============================================`);
  console.log(`TOTAL UNIQUE PANDALS COLLECTED: ${allPandals.length}`);
  console.log(`==============================================\n`);

  let count = 0;
  for (const item of allPandals) {
    count++;
    console.log(`[${count}/${allPandals.length}] Processing: ${item.name} (${item.sourceFile})`);

    // Upload local images to Cloudinary if configured
    const cloudinaryUrls = [];
    if (item.local_images && item.local_images.length > 0) {
      for (const imgPath of item.local_images) {
        const fullGithubImgUrl = GITHUB_BASE_URL + imgPath;
        const cUrl = await uploadToCloudinary(fullGithubImgUrl);
        if (cUrl) {
          cloudinaryUrls.push(cUrl);
        } else {
          // Fallback directly to GitHub Raw URL
          cloudinaryUrls.push(fullGithubImgUrl);
        }
      }
    }

    const area = deriveArea(item.name, item.description || '', item.sourceFile);

    // Check if pandal exists by name
    const existingRecord = await prisma.pandal.findFirst({
      where: { name: item.name },
    });

    let pandalRecord;
    if (existingRecord) {
      pandalRecord = await prisma.pandal.update({
        where: { id: existingRecord.id },
        data: {
          area: area,
          description: item.description || existingRecord.description,
          latitude: item.latitude || existingRecord.latitude,
          longitude: item.longitude || existingRecord.longitude,
          isFeatured2026: item.isMustVisit || existingRecord.isFeatured2026,
        },
      });
    } else {
      pandalRecord = await prisma.pandal.create({
        data: {
          name: item.name,
          area: area,
          committeeName: item.name,
          description: item.description || '',
          latitude: item.latitude,
          longitude: item.longitude,
          isFeatured2026: item.isMustVisit || false,
          category: 'THEME_BASED',
          visitStartTime: '09:00',
          visitEndTime: '23:59',
          crowdLevel: 'HIGH',
        },
      });
    }

    // Save/link photos
    if (cloudinaryUrls.length > 0) {
      for (let i = 0; i < cloudinaryUrls.length; i++) {
        const photoUrl = cloudinaryUrls[i];
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
        }
      }
    }
  }

  console.log('\n--- GITHUB TO CLOUDINARY & DB SYNC COMPLETED SUCCESSFULLY ---');
}

run().catch(console.error).finally(() => prisma.$disconnect());

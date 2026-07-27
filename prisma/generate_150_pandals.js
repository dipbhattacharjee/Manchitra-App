const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const defaultPhotos = [
  'https://res.cloudinary.com/mizoda0v/image/upload/v1784038553/579c3d50-c14f-49f4-accd-1a6d29de66e1_u8k0dq.jpg',
  'https://res.cloudinary.com/mizoda0v/image/upload/v1784038970/114045851_baf6ub.png',
  'https://res.cloudinary.com/mizoda0v/image/upload/v1784039236/ekdalia-evergreen_fbvbsr.jpg',
  'https://res.cloudinary.com/mizoda0v/image/upload/v1784039272/inauguration-ceremony-of-the-57th-year-of-youth-association-of-mohammad-ali-park-durga-puja-6_culxki.jpg',
  'https://res.cloudinary.com/mizoda0v/image/upload/v1784036075/tallest-goddess-durga-idol_kfdgox.webp',
  'https://res.cloudinary.com/mizoda0v/image/upload/v1784043552/sreebhumi_sporting_club_pnyf33.jpg',
  'https://res.cloudinary.com/mizoda0v/image/upload/v1784040072/ed6f162b-dea4-40ea-90d8-6612efc37222_1_105_c_k0rks6.jpg',
  'https://res.cloudinary.com/mizoda0v/image/upload/v1784040526/pexels-kolkatarchobiwala-15873620_nswflq.jpg',
  'https://images.unsplash.com/photo-1620608581699-23c21a48c6a2?w=600',
  'https://images.unsplash.com/photo-1567157577867-05ccb1388e66?w=600',
];

const areas = [
  'North Kolkata', 'South Kolkata', 'Central Kolkata', 'Salt Lake',
  'Behala', 'Howrah', 'Dum Dum', 'Jadavpur', 'Ballygunge', 'Shyambazar',
  'Kumartuli', 'Ahiritola', 'Kasba', 'Lake Town', 'Garia', 'New Town'
];

const categories = [
  'FAMOUS_HERITAGE', 'THEME_BASED', 'TRADITIONAL_BAROWARI', 'ECO_FRIENDLY', 'COMMUNITY'
];

const crowdLevels = ['LOW', 'MEDIUM', 'HIGH', 'VERY_HIGH'];

// Heritage Household Bonedi Bari List
const bonediBaris = [
  { name: 'Shovabazar Rajbari (Deb Family)', area: 'Shovabazar', lat: 22.5947, lng: 88.3649, desc: 'Started in 1757 by Raja Nabakrishna Deb in the presence of Lord Clive. Iconic ancestral courtyard puja.' },
  { name: 'Sabarna Roy Choudhury Bari (Barisha)', area: 'Barisha', lat: 22.4834, lng: 88.3249, desc: 'The oldest recorded Durga Puja in Kolkata, dating back to 1610.' },
  { name: 'Jorasanko Dawn Bari', area: 'Jorasanko', lat: 22.5834, lng: 88.3610, desc: 'Ancestral household puja of Shibkrishna Dawn, famous for gold and silver ornaments on traditional idols.' },
  { name: 'Pathuriaghata Khelat Ghosh Bari', area: 'Pathuriaghata', lat: 22.5913, lng: 88.3579, desc: 'Celebrated in the historic Khelat Bhavan mansion, featuring an 85-foot long marble Thakur Dalan.' },
  { name: 'Jorasanko Shib Krishna Deb Bari', area: 'Jorasanko', lat: 22.5847, lng: 88.3619, desc: 'Famous ancestral house puja known for heritage architecture and traditional Bengali rituals.' },
  { name: 'Thanthania Dutta Bari', area: 'College Street', lat: 22.5789, lng: 88.3659, desc: 'Dating back to 1855, featuring the idol of Hara-Gouri (goddess sitting on Shiva\'s lap).' },
  { name: 'Rani Rashmoni Bari (Janbazar)', area: 'Janbazar', lat: 22.5621, lng: 88.3541, desc: 'Historical puja started by Rani Rashmoni, attended by Sri Ramakrishna Paramahamsa.' },
  { name: 'Laha Bari (Beadon Street)', area: 'Beadon Street', lat: 22.5872, lng: 88.3662, desc: 'Famous ancestral family puja known for its unique custom where Durga has no Mahishasura.' },
  { name: 'Bholanath Dham Dutta Bari', area: 'Beadon Street', lat: 22.5881, lng: 88.3671, desc: 'Renowned for traditional Chala pratima and classical dhaki performances.' },
  { name: 'Mallick Bari (Bhowanipore)', area: 'Bhowanipore', lat: 22.5312, lng: 88.3482, desc: 'Heritage family puja of the famous Mallick family (Ranjit & Koel Mallick).' },
  { name: 'Chhatubabu Latubabu Bari', area: 'Beadon Street', lat: 22.5890, lng: 88.3650, desc: 'Started in 1780 by Ramdulal Dey, famous for its pair of silver peacocks on the idol frame.' },
  { name: 'Dorjibari Mitra Bari', area: 'Shyampukur', lat: 22.5930, lng: 88.3670, desc: 'Famous for traditional idol with distinctive throne and royal bhog offerings.' },
  { name: 'Maniktala Saha Bari', area: 'Maniktala', lat: 22.5810, lng: 88.3740, desc: 'Traditional Bengali merchant family puja preserving 150-year-old customs.' },
  { name: 'Pathuriaghata Seal Bari', area: 'Pathuriaghata', lat: 22.5920, lng: 88.3585, desc: 'Ancestral mansion puja of Motilal Seal family known for classical music arati.' },
  { name: 'Kundu Bari (Bhawanipur)', area: 'Bhawanipur', lat: 22.5330, lng: 88.3475, desc: 'Heritage courtyard puja with traditional ekchala pratima and sandalwood fragrance.' },
  { name: 'Halder Bari (Kalighat)', area: 'Kalighat', lat: 22.5190, lng: 88.3450, desc: 'Historic family puja with touchstone deity and centuries-old tantric traditions.' },
  { name: 'Akrur Dutta Bari', area: 'Wellington', lat: 22.5660, lng: 88.3610, desc: 'Started in 18th century, famous for classical silver saaj on traditional clay idol.' },
  { name: 'Bowbazar Sen Bari', area: 'Bowbazar', lat: 22.5690, lng: 88.3630, desc: 'Historic merchant house puja maintaining strict vegetarian bhog offerings.' },
  { name: 'Sovabazar Chhota Rajbari', area: 'Shovabazar', lat: 22.5952, lng: 88.3642, desc: 'Branch of the royal Deb family situated opposite the main Rajbari mansion.' },
  { name: 'Kumartuli Paul Bari', area: 'Kumartuli', lat: 22.5960, lng: 88.3605, desc: 'Artisan master family puja celebrating traditional idol carving heritage.' },
];

// Barowari / Theme Pandal Names List to complete 150+
const pandalNames = [
  'Bagbazar Sarbojanin', 'Kumartuli Park Durgotsav', 'Ekdalia Evergreen', 'Mohammad Ali Park',
  'Deshapriya Park', 'Sreebhumi Sporting Club', 'College Square Sarbojanin', 'Suruchi Sangha',
  'Tridhara Sammilani', 'Bosepukur Sitalamandir', 'Nalin Sarkar Street', 'Mudiali Club',
  'Badamtala Ashar Sangha', 'Ahiritola Sarbojanin', 'Santosh Mitra Square', 'Chetla Agrani Club',
  'Kashi Bose Lane', 'Hatibagan Sarbojanin', 'Samaj Sebi Sangha', 'Babubagan Club',
  'Selimpur Club', 'Singhi Park', 'Maddox Square', 'Ballygunge Cultural', 'FD Block Salt Lake',
  'BJ Block Salt Lake', 'AK Block Salt Lake', 'Dum Dum Park Tarun Sangha', 'Dum Dum Park Bharat Chakra',
  'Lake Town Adhibasi Vrinda', 'Naktala Udayan Sangha', 'Behala Nutan Dal', 'Behala Club',
  'Chaltabagan Durgotsav', 'Tala Barowari', 'Sovabazar Beniatola', 'Pathuriaghata 5 Para',
  'Gariahat Hindusthan Park', 'Hindusthan Club', 'Jodhpur Park Durgotsav', 'Ballygunge Place Sarbojanin',
  'Santoshpur Lake Pally', 'Kasba Bosepukur Parijat', 'Golf Green Sharad Utsav', 'Jadavpur Navatri Association',
  'Patuli Sharad Utsav', 'Prince Anwar Shah Road Association', 'Charu Market Club', 'Tollygunge Karunamoyee',
  'Haridevpur 41 Pally', 'Ajeya Sanghati Club', 'Barisha Club', 'New Alipore Block O',
  'Tarikahat Durgotsav', 'Bhowanipore 75 Pally', 'Padmapukur Youth Association', 'Lansdowne Sporting Club',
  'Kalighat Milan Sangha', 'Southern Avenue Club', 'Deshapriya Park North', 'Hazra Park Park Durgotsav',
  'Harish Park Sarbojanin', 'Netaji Subhas Bose Road Club', 'Chetla Friends Club', 'Kalighat Youth Club',
  'Ballygunge Place East', 'Keyatala Road Sarbojanin', 'Dhakuria Sri Ramkrishna Club', 'Garfa Main Road Pally',
  'Kasba New Town Club', 'Ruby Crossing Youth', 'E M Bypass Utsav', 'Anandapur Cultural Club',
  'Mukundapur Sarbojanin', 'Panchasayer Durgotsav', 'Highland Park Association', 'Garia Station Road Club',
  'Brahmapur Sammilani', 'Bansdroni Sporting', 'Ranikuthi Cultural', 'Tollygunge Club Pally',
  'Siriti Sporting Club', 'Silpara Youth Club', 'Thakurpuruk Durgotsav', 'Joka Town Club',
  'Maheshtala Sarbojanin', 'Batanagar Riverview Club', 'Taratala Port Colony', 'Mominpur Friends',
  'Khidirpur Dock Club', 'Hastings Recreation Club', 'Babu Ghat Association', 'Strand Road Sarbojanin',
  'BBD Bagh Central Utsav', 'Burrabazar Mint Club', 'Posta Merchant Association', 'Girish Park Cultural',
  'Shyambazar Five Point Club', 'Maniktala Sporting', 'Kankurgachi Mitali Sangha', 'Phoolbagan Youth Club',
  'Beliaghata 33 Pally', 'Sealdah Athletic Club', 'Entally Market Club', 'Park Circus Cultural',
  'Tangra Youth Association', 'Topsia Sports Club', 'Tiljala Sarbojanin', 'Kasba Industrial Club',
  'Salt Lake City Center Pally', 'Salt Lake EC Block Park', 'Salt Lake Labony Estate', 'Salt Lake GD Block',
  'Salt Lake FE Block', 'Salt Lake CC Block', 'Salt Lake BA Block', 'Salt Lake CA Block',
  'New Town Action Area 1', 'New Town Clock Tower Pally', 'New Town Eco Park Club', 'Rajarhat Main Road Utsav',
  'VIP Road Teghoria Club', 'Baguiati Jora Mandir', 'Kestopur Masterda Surya Sen', 'Lake Town Clock Tower',
  'Dum Dum Station Road', 'Nagerbazar Sarbojanin', 'Birati Youth Association', 'Belgharia Sporting',
  'Sodepur Central Club', 'Barrackpore Heritage', 'Howrah AC Market Pally', 'Howrah Maidan Club',
  'Salkia Sarbojanin', 'Bally Athletic Association', 'Botanical Garden Pally', 'Shibpur Sporting Club'
];

async function seed150Pandals() {
  console.log('Seeding 150+ Kolkata Pandals & Bonedi Bari dataset...');
  let createdCount = 0;

  // 1. Insert Bonedi Bari Household Pujas
  for (let i = 0; i < bonediBaris.length; i++) {
    const bb = bonediBaris[i];
    const photoUrl = defaultPhotos[i % defaultPhotos.length];
    
    await prisma.pandal.upsert({
      where: { id: `bonedi_${i + 1}` },
      update: {
        name: bb.name,
        area: bb.area,
        category: 'FAMOUS_HERITAGE',
        description: bb.desc,
      },
      create: {
        id: `bonedi_${i + 1}`,
        name: bb.name,
        area: bb.area,
        latitude: bb.lat,
        longitude: bb.lng,
        committeeName: `${bb.name} Estate`,
        theme: 'Traditional Heritage Idol',
        description: bb.desc,
        category: 'FAMOUS_HERITAGE',
        isFeatured2026: true,
        visitStartTime: '08:00',
        visitEndTime: '22:00',
        crowdLevel: 'MEDIUM',
        photos: {
          create: [{ url: photoUrl, isCover: true }]
        }
      }
    });
    createdCount++;
  }

  // 2. Insert 130+ Community & Theme Pandals
  for (let i = 0; i < pandalNames.length; i++) {
    const name = pandalNames[i];
    const area = areas[i % areas.length];
    const category = categories[i % categories.length];
    const crowdLevel = crowdLevels[i % crowdLevels.length];
    const photoUrl = defaultPhotos[i % defaultPhotos.length];
    const lat = 22.45 + (Math.sin(i) * 0.15) + 0.1;
    const lng = 88.30 + (Math.cos(i) * 0.12) + 0.08;

    await prisma.pandal.upsert({
      where: { id: `pandal_150_${i + 1}` },
      update: {
        name: name,
        area: area,
      },
      create: {
        id: `pandal_150_${i + 1}`,
        name: name,
        area: area,
        latitude: lat,
        longitude: lng,
        committeeName: `${name} Committee`,
        theme: `Festive Heritage Art ${i + 1}`,
        description: `Famous Kolkata Durga Puja in ${area} known for grand artistic installations and vibrant festive spirit.`,
        category: category,
        isFeatured2026: i < 15,
        visitStartTime: '09:00',
        visitEndTime: '23:59',
        crowdLevel: crowdLevel,
        photos: {
          create: [{ url: photoUrl, isCover: true }]
        }
      }
    });
    createdCount++;
  }

  console.log(`Successfully seeded ${createdCount} Kolkata Pandals & Bonedi Baris into Database!`);
  await prisma.$disconnect();
}

seed150Pandals().catch(e => {
  console.error(e);
  prisma.$disconnect();
});

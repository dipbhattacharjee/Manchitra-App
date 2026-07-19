const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const pandalData = [
  {
    name: 'Bagbazar Sarbojanin Durgotsav',
    area: 'Bagbazar',
    ward: '7',
    committeeName: 'Bagbazar Sarbojanin Durgotsab Committee',
    theme: 'Sovereign traditional alpana and classic vintage Durga idol',
    description: 'One of the oldest and most grand traditional Pujas in Kolkata, running since 1919. Famous for its traditional "Ekchala" Durga idol and the iconic Sindoor Khela.',
    isFeatured2026: true,
    category: 'FAMOUS_HERITAGE',
    latitude: 22.601287,
    longitude: 88.366472,
    visitStartTime: '00:00',
    visitEndTime: '23:59',
    crowdLevel: 'VERY_HIGH',
  },
  {
    name: 'Sreebhumi Sporting Club',
    area: 'Lake Town',
    ward: '40',
    committeeName: 'Sreebhumi Sporting Club Committee',
    theme: 'Vatican City / Roman Colosseum replica',
    description: 'Known for creating spectacular, lavish replicas of world-famous heritage monuments and decorating the Durga idol with pure gold ornaments.',
    isFeatured2026: true,
    category: 'FAMOUS_HERITAGE',
    latitude: 22.599723,
    longitude: 88.402638,
    visitStartTime: '08:00',
    visitEndTime: '23:59',
    crowdLevel: 'VERY_HIGH',
  },
  {
    name: 'Ekdalia Evergreen Club',
    area: 'Gariahat',
    ward: '68',
    committeeName: 'Ekdalia Evergreen Durgotsav Committee',
    theme: 'South Indian Temple replica with grand lighting',
    description: 'A massive crowd-puller in South Kolkata since 1943. Known for its traditional clay idols and jaw-dropping lighting work from Chandannagar.',
    isFeatured2026: true,
    category: 'FAMOUS_HERITAGE',
    latitude: 22.518671,
    longitude: 88.368759,
    visitStartTime: '09:00',
    visitEndTime: '23:59',
    crowdLevel: 'HIGH',
  },
  {
    name: 'College Square Sarbojanin',
    area: 'Central Kolkata',
    ward: '40',
    committeeName: 'College Square Sarbojanin Durgotsav Committee',
    theme: 'Illumination, Waterfront, Heritage',
    description: 'Renowned for its massive, dazzling light installations. The primary structure is built on a massive lake inside the park, casting a flawless reflection of the illuminated design over the water at night.',
    isFeatured2026: true,
    category: 'FAMOUS_HERITAGE',
    latitude: 22.574697,
    longitude: 88.363989,
    visitStartTime: '12:00',
    visitEndTime: '23:59',
    crowdLevel: 'HIGH',
  },
  {
    name: 'Kumartuli Park Durgotsav',
    area: 'Kumartuli',
    ward: '9',
    committeeName: 'Kumartuli Park Sporting Club',
    theme: 'Artisan\'s Heritage and Traditional Clay Work',
    description: 'Located right next to the potter\'s quarter in North Kolkata, showcasing outstanding idol craftsmanship and creative themes.',
    isFeatured2026: true,
    category: 'FAMOUS_HERITAGE',
    latitude: 22.597652,
    longitude: 88.361201,
    visitStartTime: '10:00',
    visitEndTime: '23:00',
    crowdLevel: 'HIGH',
  },
  {
    name: 'Suruchi Sangha',
    area: 'South Kolkata',
    ward: '81',
    committeeName: 'New Alipore Suruchi Sangha Committee',
    theme: 'State-Themes, Cultural Diversity, High Crowd',
    description: 'Famous for depicting a unique Indian state\'s art, handicraft, and lifestyle traditions every year. The idol\'s features and attire are meticulously styled to mirror the chosen state\'s heritage.',
    isFeatured2026: true,
    category: 'FAMOUS_HERITAGE',
    latitude: 22.519098,
    longitude: 88.337762,
    visitStartTime: '09:00',
    visitEndTime: '23:59',
    crowdLevel: 'HIGH',
  },
  {
    name: 'Tridhara Sammilani',
    area: 'Ballygunge',
    ward: '84',
    committeeName: 'Tridhara Sammilani Committee',
    theme: 'Traditional Indian tribal art and folklore',
    description: 'An artistic powerhouse in Ballygunge that blends modern creative theme design with ancient Indian arts and crafts.',
    isFeatured2026: false,
    category: 'THEME_BASED',
    latitude: 22.520448,
    longitude: 88.364998,
    visitStartTime: '10:00',
    visitEndTime: '23:00',
    crowdLevel: 'MEDIUM',
  },
  {
    name: 'Bosepukur Sitalamandir',
    area: 'Kasba',
    ward: '91',
    committeeName: 'Bosepukur Sitalamandir Committee',
    theme: 'Rural earthen pottery and clay craftsmanship',
    description: 'Famous for its innovative use of everyday elements (like clay cups, hand-fans, or bicycle parts) to create intricate pandal structures.',
    isFeatured2026: false,
    category: 'THEME_BASED',
    latitude: 22.522105,
    longitude: 88.384612,
    visitStartTime: '09:00',
    visitEndTime: '23:00',
    crowdLevel: 'MEDIUM',
  },
  {
    name: 'Nalin Sarkar Street',
    area: 'Shyambazar',
    ward: '10',
    committeeName: 'Nalin Sarkar Street Durgotsab Committee',
    theme: 'Miniature wood carvings and hand-painted pottery',
    description: 'A critically acclaimed north Kolkata puja that transforms a narrow alley into a museum of detailed folk art.',
    isFeatured2026: false,
    category: 'THEME_BASED',
    latitude: 22.593456,
    longitude: 88.368924,
    visitStartTime: '11:00',
    visitEndTime: '22:30',
    crowdLevel: 'MEDIUM',
  },
  {
    name: 'Mudiali Club',
    area: 'Tollygunge',
    ward: '88',
    committeeName: 'Mudiali Club Durgotsab Committee',
    theme: 'Devotional classical temple architecture and alpana',
    description: 'Known for elegant and tasteful setups that remain true to traditional aesthetic structures with elegant color harmony.',
    isFeatured2026: false,
    category: 'THEME_BASED',
    latitude: 22.510344,
    longitude: 88.349887,
    visitStartTime: '09:00',
    visitEndTime: '23:59',
    crowdLevel: 'MEDIUM',
  },
  {
    name: 'Badamtala Ashar Sangha',
    area: 'South Kolkata (Kalighat)',
    ward: '83',
    committeeName: 'Badamtala Ashar Sangha Committee',
    theme: 'Experimental Theme, Trendsetter, Compact Pandal',
    description: 'Celebrated as one of the definitive pioneers of modern "theme-based" pujas in Kolkata. Though set within narrow lanes, it showcases highly creative, intimate design motifs that pull heavy crowds yearly.',
    isFeatured2026: false,
    category: 'THEME_BASED',
    latitude: 22.518921,
    longitude: 88.347898,
    visitStartTime: '10:00',
    visitEndTime: '23:00',
    crowdLevel: 'MEDIUM',
  },
  {
    name: 'Ahiritola Sarbojanin Durgotsab',
    area: 'Ahiritola',
    ward: '20',
    committeeName: 'Ahiritola Sarbojanin Durgotsab Committee',
    theme: 'Tribute to the street artists and alpana heritage',
    description: 'Running since 1940, it is famous for its large-scale creative theme work depicting rural livelihood and traditional folk arts.',
    isFeatured2026: false,
    category: 'THEME_BASED',
    latitude: 22.595992,
    longitude: 88.358764,
    visitStartTime: '08:00',
    visitEndTime: '23:00',
    crowdLevel: 'HIGH',
  },
  {
    name: 'Shovabazar Rajbari (Deb Family)',
    area: 'Shovabazar',
    ward: '9',
    committeeName: 'Shovabazar Rajbari Estate',
    theme: 'Historic Daker Saaj Sabekiana (Traditional Deb Family idol)',
    description: 'Started in 1757 by Raja Nabakrishna Deb in the presence of Lord Clive. This is one of the most famous ancestral household pujas in Bengal.',
    isFeatured2026: true,
    category: 'FAMOUS_HERITAGE',
    latitude: 22.594723,
    longitude: 88.364898,
    visitStartTime: '10:00',
    visitEndTime: '22:00',
    crowdLevel: 'MEDIUM',
  },
  {
    name: 'Sabarna Roy Choudhury Bari (Barisha)',
    area: 'Barisha',
    ward: '123',
    committeeName: 'Sabarna Roy Choudhury Paribar',
    theme: 'Aatchala traditional idol representing the ancestral landlords',
    description: 'The oldest recorded Durga Puja in Kolkata, dating back to 1610. The family landlord Sabarna Roy Choudhury sold Kolkata to the British East India Company.',
    isFeatured2026: true,
    category: 'FAMOUS_HERITAGE',
    latitude: 22.483448,
    longitude: 88.324898,
    visitStartTime: '08:00',
    visitEndTime: '22:00',
    crowdLevel: 'LOW',
  },
  {
    name: 'Jorasanko Dawn Bari',
    area: 'Jorasanko',
    ward: '25',
    committeeName: 'Dawn Mansion Estate',
    theme: 'Traditional clay idol with pure gold embellishments (Daker Saaj)',
    description: 'The ancestral household puja of Shibkrishna Dawn. Known for the grand mansion courtyard (Thakur Dalan) and gold/silver decorations of the deities.',
    isFeatured2026: true,
    category: 'FAMOUS_HERITAGE',
    latitude: 22.583448,
    longitude: 88.360987,
    visitStartTime: '09:00',
    visitEndTime: '22:00',
    crowdLevel: 'LOW',
  },
  {
    name: 'Pathuriaghata Khelat Ghosh Bari',
    area: 'Pathuriaghata',
    ward: '24',
    committeeName: 'Khelat Ghosh Mansion Estate',
    theme: 'Sabek traditional Durga idol in a grand marble courtyard',
    description: 'Celebrated in the historic Khelat Bhavan mansion, featuring a stunning 85-foot long marble corridor (Thakur Dalan) and traditional rituals.',
    isFeatured2026: true,
    category: 'FAMOUS_HERITAGE',
    latitude: 22.591287,
    longitude: 88.357898,
    visitStartTime: '10:00',
    visitEndTime: '21:00',
    crowdLevel: 'LOW',
  },
  {
    name: 'Jorasanko Shib Krishna Deb Bari',
    area: 'Jorasanko',
    ward: '25',
    committeeName: 'Deb Mansion Estate',
    theme: 'Heritage family puja with standard traditional clay work',
    description: 'Famous ancestral house puja known for its heritage architecture and maintaining the strict, centuries-old Bengali puja rituals.',
    isFeatured2026: false,
    category: 'FAMOUS_HERITAGE',
    latitude: 22.584723,
    longitude: 88.361898,
    visitStartTime: '09:00',
    visitEndTime: '21:00',
    crowdLevel: 'LOW',
  },
  {
    name: 'Thanthania Dutta Bari',
    area: 'College Street',
    ward: '37',
    committeeName: 'Dutta Mansion Estate',
    theme: 'Hara-Gouri theme idol where Durga sits on Shiva\'s lap',
    description: 'Dating back to 1855, this ancestral puja is unique because the Durga idol is styled as Hara-Gouri (sitting on Shiva\'s lap) rather than killing the demon.',
    isFeatured2026: false,
    category: 'FAMOUS_HERITAGE',
    latitude: 22.578921,
    longitude: 88.365898,
    visitStartTime: '08:00',
    visitEndTime: '22:00',
    crowdLevel: 'LOW',
  },
  {
    name: 'Deshapriya Park',
    area: 'South Kolkata',
    ward: '85',
    committeeName: 'Deshapriya Park Durga Puja',
    theme: 'Ganges Revived',
    description: 'Deshapriya Park 2026 focuses on a water conservation theme, with a stunning pandal built around the concept of a revived Ganges.',
    isFeatured2026: true,
    category: 'ECO_FRIENDLY',
    latitude: 22.5272,
    longitude: 88.3629,
    visitStartTime: '09:00',
    visitEndTime: '23:59',
    crowdLevel: 'HIGH',
  },
  {
    name: 'Mohammad Ali Park',
    area: 'Central Kolkata',
    ward: '43',
    committeeName: 'Mohammad Ali Park Durga Puja Committee',
    theme: 'Eco-Future',
    description: 'A central Kolkata institution known for massive pandal structures and eco-friendly innovation. The 2026 theme explores sustainability.',
    isFeatured2026: true,
    category: 'ECO_FRIENDLY',
    latitude: 22.5751,
    longitude: 88.3674,
    visitStartTime: '09:00',
    visitEndTime: '23:00',
    crowdLevel: 'VERY_HIGH',
  },
  {
    name: 'Santosh Mitra Square (Bowbazar)',
    area: 'Central Kolkata',
    ward: '50',
    committeeName: 'Santosh Mitra Square Committee',
    theme: 'Big Budget, Grand Opulence, High Crowd',
    description: 'One of the most visited big-budget spectacles in central Kolkata. Famous for extravagant setups, ranging from gold/silver clad structures to jaw-dropping replicas of monuments. Expect heavy foot traffic.',
    isFeatured2026: true,
    category: 'THEME_BASED',
    latitude: 22.5684,
    longitude: 88.3644,
    visitStartTime: '09:00',
    visitEndTime: '23:59',
    crowdLevel: 'VERY_HIGH',
  },
  {
    name: 'Chetla Agrani Club',
    area: 'South Kolkata (Chetla)',
    ward: '82',
    committeeName: 'Chetla Agrani Club Committee',
    theme: 'Eco-Friendly, Conceptual Art, Award-Winner',
    description: 'A legendary powerhouse for installation art. It relies heavily on eco-friendly, natural elements (like millions of rudraksha seeds or specialized wood crafts) to tell a profound sociological or spiritual story.',
    isFeatured2026: true,
    category: 'ECO_FRIENDLY',
    latitude: 22.5181,
    longitude: 88.3444,
    visitStartTime: '09:00',
    visitEndTime: '23:59',
    crowdLevel: 'HIGH',
  },
];

async function main() {
  console.log('Seeding database with Kolkata Durga Puja pandals...');
  
  // Clean existing photos and pandals
  await prisma.pandalPhoto.deleteMany();
  await prisma.pandal.deleteMany();
  console.log('Cleared existing pandal and photo records.');

  for (const p of pandalData) {
    const pandal = await prisma.pandal.create({
      data: p,
    });
    console.log(`Successfully created: ${pandal.name} (${pandal.area})`);

    if (pandal.name === 'Deshapriya Park') {
      await prisma.pandalPhoto.create({
        data: {
          pandalId: pandal.id,
          url: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784036075/tallest-goddess-durga-idol_kfdgox.webp',
          isCover: true,
        }
      });
      console.log('Successfully seeded photo for Deshapriya Park');
    }

    if (pandal.name === 'Bagbazar Sarbojanin Durgotsav') {
      await prisma.pandalPhoto.create({
        data: {
          pandalId: pandal.id,
          url: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784038553/579c3d50-c14f-49f4-accd-1a6d29de66e1_u8k0dq.jpg',
          isCover: true,
        }
      });
      await prisma.pandalPhoto.create({
        data: {
          pandalId: pandal.id,
          url: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784040526/pexels-kolkatarchobiwala-15873620_nswflq.jpg',
          isCover: false,
        }
      });
      console.log('Successfully seeded photos for Bagbazar Sarbojanin');
    }

    if (pandal.name === 'Kumartuli Park Durgotsav') {
      await prisma.pandalPhoto.create({
        data: {
          pandalId: pandal.id,
          url: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784038970/114045851_baf6ub.png',
          isCover: true,
        }
      });
      console.log('Successfully seeded photo for Kumartuli Park Durgotsav');
    }

    if (pandal.name === 'Ekdalia Evergreen Club') {
      await prisma.pandalPhoto.create({
        data: {
          pandalId: pandal.id,
          url: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784039236/ekdalia-evergreen_fbvbsr.jpg',
          isCover: true,
        }
      });
      console.log('Successfully seeded photo for Ekdalia Evergreen Club');
    }

    if (pandal.name === 'Mohammad Ali Park') {
      await prisma.pandalPhoto.create({
        data: {
          pandalId: pandal.id,
          url: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784039272/inauguration-ceremony-of-the-57th-year-of-youth-association-of-mohammad-ali-park-durga-puja-6_culxki.jpg',
          isCover: true,
        }
      });
      await prisma.pandalPhoto.create({
        data: {
          pandalId: pandal.id,
          url: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784039277/Inauguration-ceremony-of-the-57th-Year-of-Youth-Association-of-Mohammad-Ali-Park-Durga-Puja_2_libo56.jpg',
          isCover: false,
        }
      });
      console.log('Successfully seeded photos for Mohammad Ali Park');
    }

    if (pandal.name === 'Jorasanko Dawn Bari') {
      await prisma.pandalPhoto.create({
        data: {
          pandalId: pandal.id,
          url: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784040072/ed6f162b-dea4-40ea-90d8-6612efc37222_1_105_c_k0rks6.jpg',
          isCover: true,
        }
      });
      await prisma.pandalPhoto.create({
        data: {
          pandalId: pandal.id,
          url: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784040526/pexels-kolkatarchobiwala-15873620_nswflq.jpg',
          isCover: false,
        }
      });
      console.log('Successfully seeded photos for Jorasanko Dawn Bari');
    }
  }
  
  console.log('Database seeding finished successfully!');
}

main()
  .catch((e) => {
    console.error('Seeding error: ', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

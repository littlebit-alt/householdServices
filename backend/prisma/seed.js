const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const prisma = new PrismaClient();

async function main() {
  const password = await bcrypt.hash('password', 12);

  await prisma.admin.upsert({
    where: { email: 'admin@household.com' },
    update: {},
    create: { fullName: 'Super Admin', email: 'admin@household.com', password, role: 'admin' }
  });

  const categories = await Promise.all([
    prisma.category.upsert({ where: { name: 'Cleaning' }, update: {}, create: { name: 'Cleaning', icon: '🧹', description: 'Home and office cleaning' } }),
    prisma.category.upsert({ where: { name: 'Plumbing' }, update: {}, create: { name: 'Plumbing', icon: '🔧', description: 'Plumbing and water pipes' } }),
    prisma.category.upsert({ where: { name: 'Electrical' }, update: {}, create: { name: 'Electrical', icon: '⚡', description: 'Electrical installation' } }),
    prisma.category.upsert({ where: { name: 'Painting' }, update: {}, create: { name: 'Painting', icon: '🎨', description: 'Interior and exterior painting' } }),
    prisma.category.upsert({ where: { name: 'Repairs' }, update: {}, create: { name: 'Repairs', icon: '🔨', description: 'General home repairs' } }),
  ]);

  await prisma.service.createMany({
    skipDuplicates: true,
    data: [
      { name: 'Deep House Cleaning', description: 'Full deep cleaning of your home', basePrice: 50, categoryId: categories[0].id },
      { name: 'Bathroom Cleaning', description: 'Deep cleaning of bathrooms', basePrice: 25, categoryId: categories[0].id },
      { name: 'Pipe Fixing', description: 'Fix leaking or broken pipes', basePrice: 40, categoryId: categories[1].id },
      { name: 'Electrical Wiring', description: 'Install or repair wiring', basePrice: 60, categoryId: categories[2].id },
      { name: 'Wall Painting', description: 'Paint interior or exterior walls', basePrice: 80, categoryId: categories[3].id },
      { name: 'Furniture Assembly', description: 'Assemble and install furniture', basePrice: 35, categoryId: categories[4].id },
    ]
  });

  console.log('✅ Database seeded!');
}

main().catch(console.error).finally(() => prisma.$disconnect());
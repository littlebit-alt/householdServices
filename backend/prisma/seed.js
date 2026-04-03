const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const prisma = new PrismaClient();

async function main() {
  const password = await bcrypt.hash('password', 12);
  
  await prisma.admin.upsert({
    where: { email: 'admin@household.com' },
    update: {},
    create: {
      fullName: 'Super Admin',
      email: 'admin@household.com',
      password,
      role: 'admin'
    }
  });

  await prisma.category.createMany({
    skipDuplicates: true,
    data: [
      { name: 'Cleaning', icon: '🧹', description: 'Home and office cleaning' },
      { name: 'Plumbing', icon: '🔧', description: 'Plumbing and water pipes' },
      { name: 'Electrical', icon: '⚡', description: 'Electrical installation' },
      { name: 'Painting', icon: '🎨', description: 'Interior and exterior painting' },
      { name: 'Repairs', icon: '🔨', description: 'General home repairs' },
    ]
  });

  console.log('✅ Database seeded!');
}

main().catch(console.error).finally(() => prisma.$disconnect());
// Import required modules
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

// Function to check if the database is available
async function checkDatabase() {

  try {
    await prisma.$connect() // Connect to the database
    return true // If successful, return true
  } catch (error) {
    console.log('couldn\'t connect to database: ', error)
      
    return false // If connection fails, return false
  } finally {
    await prisma.$disconnect() // Disconnect from the database
  }
}

// Function to wait for the database to be available
async function waitForDatabase() {
  console.log('Waiting for database...')

  let dbAvailable = false
  while (!dbAvailable) {
    dbAvailable = await checkDatabase() // Check if the database is available
    if (!dbAvailable) {
      console.log('Database unavailable, waiting 1 second...')
      await new Promise(resolve => setTimeout(resolve, 1000)) // Wait for 1 second
    }
  }

  console.log('Database available!')
}

// Call the function to wait for the database
waitForDatabase()

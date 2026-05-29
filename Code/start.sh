#!/bin/bash

echo "🚀 Starting OLAP Web Interface..."
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null
then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

echo "✅ Node.js version: $(node --version)"
echo ""

# Start backend server
echo "🔧 Starting Backend Server (port 5000)..."
cd server
npm start &
BACKEND_PID=$!

# Wait for backend to start
sleep 2

# Start frontend
echo "🎨 Starting Frontend (port 3000)..."
cd ../client
npm start &
FRONTEND_PID=$!

# Wait for user to stop
wait

# Kill both processes
kill $BACKEND_PID $FRONTEND_PID 2>/dev/null
echo "✅ Application stopped"

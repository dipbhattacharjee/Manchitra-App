-- CreateEnum
CREATE TYPE "GroupType" AS ENUM ('SOLO', 'COUPLE', 'FAMILY', 'GROUP');

-- CreateEnum
CREATE TYPE "AppTheme" AS ENUM ('TRADITIONAL', 'COUPLE', 'FAMILY', 'HERITAGE');

-- CreateEnum
CREATE TYPE "PandalCategory" AS ENUM ('TRADITIONAL_BAROWARI', 'THEME_BASED', 'ECO_FRIENDLY', 'COMMUNITY', 'FAMOUS_HERITAGE');

-- CreateEnum
CREATE TYPE "CrowdLevel" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'VERY_HIGH');

-- CreateEnum
CREATE TYPE "RouteType" AS ENUM ('FASTEST', 'SHORTEST', 'WALKING_FRIENDLY');

-- CreateEnum
CREATE TYPE "TransportMode" AS ENUM ('WALK', 'METRO', 'TRAIN', 'CAB', 'AUTO');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "phone" TEXT,
    "email" TEXT,
    "name" TEXT,
    "homeArea" TEXT,
    "groupType" "GroupType" NOT NULL DEFAULT 'SOLO',
    "preferredTheme" "AppTheme" NOT NULL DEFAULT 'TRADITIONAL',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Pandal" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "area" TEXT NOT NULL,
    "ward" TEXT,
    "committeeName" TEXT,
    "theme" TEXT,
    "description" TEXT,
    "isFeatured2026" BOOLEAN NOT NULL DEFAULT false,
    "category" "PandalCategory" NOT NULL DEFAULT 'THEME_BASED',
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "visitStartTime" TEXT,
    "visitEndTime" TEXT,
    "crowdLevel" "CrowdLevel" NOT NULL DEFAULT 'MEDIUM',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Pandal_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PandalPhoto" (
    "id" TEXT NOT NULL,
    "pandalId" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "isCover" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "PandalPhoto_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Trip" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "tripDate" TIMESTAMP(3) NOT NULL,
    "title" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Trip_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TripStop" (
    "id" TEXT NOT NULL,
    "tripId" TEXT NOT NULL,
    "pandalId" TEXT NOT NULL,
    "visitOrder" INTEGER NOT NULL,
    "plannedTime" TEXT,
    "visited" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "TripStop_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Route" (
    "id" TEXT NOT NULL,
    "tripId" TEXT,
    "userId" TEXT NOT NULL,
    "routeType" "RouteType" NOT NULL DEFAULT 'FASTEST',
    "totalDistanceKm" DOUBLE PRECISION NOT NULL,
    "totalTimeMin" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Route_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RouteLeg" (
    "id" TEXT NOT NULL,
    "routeId" TEXT NOT NULL,
    "sequenceOrder" INTEGER NOT NULL,
    "fromPandalId" TEXT NOT NULL,
    "toPandalId" TEXT NOT NULL,
    "distanceKm" DOUBLE PRECISION NOT NULL,
    "durationMin" INTEGER NOT NULL,
    "suggestedMode" "TransportMode" NOT NULL,

    CONSTRAINT "RouteLeg_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FoodPlace" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "area" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "cuisine" TEXT,
    "priceRange" TEXT,
    "isVeg" BOOLEAN,
    "rating" DOUBLE PRECISION,

    CONSTRAINT "FoodPlace_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Hotel" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "area" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "priceRange" TEXT,
    "rating" DOUBLE PRECISION,

    CONSTRAINT "Hotel_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MetroStation" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "line" TEXT NOT NULL,

    CONSTRAINT "MetroStation_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_phone_key" ON "User"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "Pandal_area_idx" ON "Pandal"("area");

-- CreateIndex
CREATE INDEX "Pandal_isFeatured2026_idx" ON "Pandal"("isFeatured2026");

-- CreateIndex
CREATE UNIQUE INDEX "Route_tripId_key" ON "Route"("tripId");

-- AddForeignKey
ALTER TABLE "PandalPhoto" ADD CONSTRAINT "PandalPhoto_pandalId_fkey" FOREIGN KEY ("pandalId") REFERENCES "Pandal"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Trip" ADD CONSTRAINT "Trip_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TripStop" ADD CONSTRAINT "TripStop_tripId_fkey" FOREIGN KEY ("tripId") REFERENCES "Trip"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TripStop" ADD CONSTRAINT "TripStop_pandalId_fkey" FOREIGN KEY ("pandalId") REFERENCES "Pandal"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Route" ADD CONSTRAINT "Route_tripId_fkey" FOREIGN KEY ("tripId") REFERENCES "Trip"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Route" ADD CONSTRAINT "Route_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RouteLeg" ADD CONSTRAINT "RouteLeg_routeId_fkey" FOREIGN KEY ("routeId") REFERENCES "Route"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RouteLeg" ADD CONSTRAINT "RouteLeg_fromPandalId_fkey" FOREIGN KEY ("fromPandalId") REFERENCES "Pandal"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RouteLeg" ADD CONSTRAINT "RouteLeg_toPandalId_fkey" FOREIGN KEY ("toPandalId") REFERENCES "Pandal"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- Add a geography column to Pandal for fast radius queries
ALTER TABLE "Pandal" ADD COLUMN geo_location geography(Point, 4326);

-- Populate geo_location from latitude/longitude
UPDATE "Pandal" SET geo_location = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography;

-- Index for fast nearest-neighbor / radius search
CREATE INDEX idx_pandal_geo ON "Pandal" USING GIST (geo_location);

-- Create trigger function to keep geo_location in sync with latitude/longitude updates
CREATE OR REPLACE FUNCTION update_pandal_geo_location()
RETURNS TRIGGER AS $$
BEGIN
    NEW.geo_location := ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326)::geography;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to Pandal table
CREATE TRIGGER trigger_update_pandal_geo_location
BEFORE INSERT OR UPDATE ON "Pandal"
FOR EACH ROW
EXECUTE FUNCTION update_pandal_geo_location();


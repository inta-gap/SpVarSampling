library(water)

aoi <- shapefile("SpVaSampling/aoi.shp")
L8 <- raster("SpVaSampling/LC08_L1TP_232083_20190321_20190403_01_T1/LC08_L1TP_232083_20190321_20190403_01_T1_B4.TIF")

aoi <- spTransform(aoi, L8@crs)
L8 <- crop(L8, aoi)
L8 <- projectRaster(L8, crs=CRS("+init=epsg:32719"))

aoi <- shapefile("SpVaSampling/aoi.shp")


s2r <- raster("SpVaSampling/T19HED_20180307T142849_B04.jp2")
s2r <- crop(s2r, aoi)

s2ir <- raster("SpVaSampling/T19HED_20180307T142849_B08.jp2")
s2ir <- crop(s2ir, aoi)

ndvi <- (s2ir - s2r)/(s2ir + s2r)

pixels <- as(L8, "SpatialPolygons")
pixels@proj4string <- aoi@proj4string

png(filename = "CAI/ndvi.png", width = 800, height = 800)
plot(ndvi)
lines(pixels)
lines(aoi, col = "blue")
dev.off()

zones <- rasterize(pixels, s2r)
variability <- zonal(ndvi, zones, fun="var")

pixels <- as(pixels, "SpatialPolygonsDataFrame")
pixels@data <- as.data.frame(variability)

pixels[[1]]

png(filename = "CAI/var.png", width = 800, height = 800)
spplot(pixels, "var")
dev.off()

hist(pixels$var)

best <- pixels[pixels$var < 0.004,]

png(filename = "CAI/best.png", width = 800, height = 800)
spplot(best, "var", col.regions= topo.colors(35))
dev.off()


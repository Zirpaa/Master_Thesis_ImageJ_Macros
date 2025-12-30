// Clear previous results
run("Clear Results");

// Get list of all open image windows
imageTitles = getList("image.titles");


// Initialise variables to store the titles of Ca-AM (live) and EthD-1 (dead) images
caamTitle = "";
ethd1Title = "";

// Find the image titles based on naming pattern
for (i = 0; i < imageTitles.length; i++) {
    if (endsWith(imageTitles[i], "d1.TIF") && caamTitle == "") {
        caamTitle = imageTitles[i];
    } else if (endsWith(imageTitles[i], "d2.TIF") && ethd1Title == "") {
        ethd1Title = imageTitles[i];
    }
}

// Function to count cells directly on the original 16-bit image
function countCellsOnOriginal(title) {
    selectWindow(title);

    // Optional debug info
    depth = bitDepth();
    print("Image: " + title + " | Bit depth: " + depth);
    getRawStatistics(area, mean, min, max);
    print("→ Min: " + min + ", Max: " + max + ", Mean: " + mean);

    // Apply threshold and convert to binary
    setThreshold(445, 65535);
    run("Convert to Mask");
    run("Fill Holes");
    run("Watershed");

    // Analyze particles and count hits
    run("Analyze Particles...", "size=20-infinite pixel clear summarize add");
    cellCount = nResults;

    // Cleanup
    run("Clear Results");
    close("Summary");
    resetThreshold();

    return cellCount;
}

// Only proceed if both required images are found
if (caamTitle != "" && ethd1Title != "") {

    // Count cells
    caamCount = countCellsOnOriginal(caamTitle);   // live cells
    ethd1Count = countCellsOnOriginal(ethd1Title); // dead cells

    totalCount = caamCount + ethd1Count;

    if (totalCount > 0) {
        viability = (caamCount / totalCount) * 100;

        // Output to console
        print("Ca-AM (live) cells: " + caamCount);
        print("EthD-1 (dead) cells: " + ethd1Count);
        print("Total cells: " + totalCount);
        print("Viability (% live): " + viability);

        // Output to Results Table (one row!)
        row = nResults; // store row once
        setResult("Image", row, caamTitle);
        setResult("Live Cells", row, caamCount);
        setResult("Dead Cells", row, ethd1Count);
        setResult("Total Cells", row, totalCount);
        setResult("Viability (%)", row, viability);
        updateResults();

    } else {
        print("Error: Total cell count is zero.");
    }

    waitForUser("Review overlays and results. Click OK to finish.");

    // Close original image windows without saving
    if (isOpen(caamTitle)) {
        selectWindow(caamTitle);
        setOption("Changes", false);
        close();
    }
    if (isOpen(ethd1Title)) {
        selectWindow(ethd1Title);
        setOption("Changes", false);
        close();
    }

} else {
    print("Error: One or both image channels (Ca-AM or EthD-1) were not found.");
}

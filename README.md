# DP

Focus-stacking a hyperspectral (HS) image.

# The main principle

The algorithm uses Laplacian pyramids to evaluate which HS image within a set of HS images is the sharpest at a given coordinate. The pixel from this coordinate is then used in the final output HS image. The pixel is chosen based on the amount of deviation in local area around the pixel.


# Main file

The mail file is called dp.m, The user can input the desired path to a set of HS images. Depending on the size a number of spectral channels of the HS image, the time required to process the image can vary. One spectral channels takes about a second to process. One full scale HS image can take up to 30 minutes to process.

# Room for improvement

Robust registration of HS images.
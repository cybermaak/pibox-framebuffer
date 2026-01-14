package pkg

type Config struct {
	diskMountPrefix string
	screenWidth     int    // Width of the screen
	screenHeight    int    // Height of the screen
	rotation        string // Rotation value as string ("0", "90", "180", "270")
	rowOffsetCfg    int    // Row offset configuration
	rowOffset       int    // Row offset
}

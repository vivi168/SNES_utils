.ifndef DEF_INC
.define DEF_INC

; RAM addresses
PLAYER_SX   = $0001
BGH_SCRL    = $0002
BGH_SCRH    = $0003
BGV_SCRL    = $0004
PLAYER_ATTR = $0005
PLAYER_MXL  = $0006
PLAYER_MXH  = $0007
UPDATE_OBJ  = $0008
JOY1_RAWL   = $0010
JOY1_RAWH   = $0011
JOY1_HELDL  = $0012
JOY1_HELDH  = $0013
JOY1_PRESSL = $0014
JOY1_PRESSH = $0015

OAML_BUF_START = $0100
OAMH_BUF_START = $0300

; constants
OAML_SIZE      = $0200
OAMH_SIZE      = $0020
OAM_SIZE       = OAML_SIZE + OAMH_SIZE

JOY_RIGHT = $01
JOY_LEFT  = $02

TILEMAP_SIZE    = $800
BG_SIZE         = $800
MARIO_SIZE      = $800
BG_PAL_SIZE     = $20
MARIO_PAL_SIZE  = $20

TILEMAP_START   = $8000
TILEMAP2_START  = TILEMAP_START + TILEMAP_SIZE
BG_START        = TILEMAP2_START + TILEMAP_SIZE
MARIO_START     = BG_START      + BG_SIZE
BG_PAL_START    = MARIO_START   + MARIO_SIZE
MARIO_PAL_START = BG_PAL_START  + BG_PAL_SIZE

.endif
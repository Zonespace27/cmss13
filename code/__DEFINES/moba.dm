#define MOBA_TESTING
//#define MOBA_MP_TESTING

#define MOBA_GOLD_NAME "Gold"
#define MOBA_GOLD_NAME_SHORT "G"

#define MOBA_LANE_TOP "Top Lane"
#define MOBA_LANE_BOT "Bottom Lane"
#define MOBA_LANE_JUNGLE "Jungle"
#define MOBA_LANE_SUPPORT "Support"

#define MOBA_ARCHETYPE_ASSASSIN "Assassin"
#define MOBA_ARCHETYPE_CONTROLLER "Controller"
#define MOBA_ARCHETYPE_CASTER "Caster"
#define MOBA_ARCHETYPE_FIGHTER "Fighter"
#define MOBA_ARCHETYPE_TANK "Tank"

#define MOBA_ALLOWED_POSITIONS 3

#define MOBA_PLAYERS_PER_TEAM 4
#define MOBA_TOTAL_PLAYERS MOBA_PLAYERS_PER_TEAM * 2

#define MOBA_MAX_LEVEL 12
#define MOBA_MAX_ITEM_COUNT 5
/// When killing a player, how much xp (mult by their level) to grant
#define MOBA_XP_ON_KILL_PER_PLAYER_LEVEL 60

#define MOBA_RESTING_HEAL_MULTIPLIER 1.5
#define MOBA_FOUNTAIN_HEAL_MULTIPLIER 40 // fountain should be ALMOST instant

#define MOBA_CS_PER_MINION 1
#define MOBA_CS_PER_CAMP 4

#define MOBA_MINION_V_MINION_DAMAGE_MULT 0.5

#define MOBA_GOLD_PER_WAVE 160
#define MOBA_MINIONS_PER_WAVE 4
#define MOBA_WAVES_PER_MINUTE 2

#define MOBA_GOLD_PER_MINUTE MOBA_GOLD_PER_WAVE * MOBA_WAVES_PER_MINUTE

#define MOBA_LEVEL_DIFF_XP_FALLOFF_THRESHOLD 2
/// Per level, so 5 levels ahead means 0 xp earned
#define MOBA_LEVEL_DIFF_XP_MOD 0.2

#define MOBA_ITEM_SELLBACK_VALUE 0.6

/// How much bonus damage to deal against structures minions/players have the hivebot boon
#define MOBA_HIVEBOT_BOON_TRUE_DAMAGE 8

/// Bonus AD from carp boon
#define MOBA_CARP_BOON_AD_MULT 1.08

/// Bonus AP from carp boon
#define MOBA_CARP_BOON_AP_MULT 1.1

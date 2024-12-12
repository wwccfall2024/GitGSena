-- Create your tables, views, functions and procedures here!
CREATE SCHEMA destruction;
USE destruction;

CREATE TABLE players (
  player_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(30) NOT NULL,
  last_name VARCHAR(30) NOT NULL,
  email VARCHAR(50) NOT NULL
);

CREATE TABLE characters (
  character_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  player_id INT UNSIGNED NOT NULL,
  name VARCHAR(50) NOT NULL,
  level INT UNSIGNED NOT NULL,
  CONSTRAINT characters_fk_players
    FOREIGN KEY (player_id)
    REFERENCES players (player_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);
CREATE TABLE winners (
  character_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  CONSTRAINT winners_fk_characters
    FOREIGN KEY (character_id)
    REFERENCES characters (character_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE TABLE character_stats (
  character_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  health TINYINT NOT NULL,
  armor TINYINT NOT NULL,
  CONSTRAINT character_stats_fk_characters
    FOREIGN KEY (character_id)
    REFERENCES characters (character_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE TABLE teams (
  team_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL
);

CREATE TABLE team_members (
  team_member_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  team_id INT UNSIGNED NOT NULL,
  character_id INT UNSIGNED NOT NULL,
  CONSTRAINT team_members_fk_teams
    FOREIGN KEY (team_id)
    REFERENCES teams (team_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT team_members_fk_characters
    FOREIGN KEY (character_id)
    REFERENCES characters (character_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE TABLE items (
  item_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  armor TINYINT NOT NULL,
  damage TINYINT NOT NULL
);

CREATE TABLE inventory (
  inventory_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  character_id INT UNSIGNED NOT NULL,
  item_id INT UNSIGNED NOT NULL,
  CONSTRAINT inventory_fk_characters
    FOREIGN KEY (character_id)
    REFERENCES characters (character_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT inventory_fk_items
    FOREIGN KEY (item_id)
    REFERENCES items (item_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE TABLE equipped (
  equipped_id INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  character_id INT UNSIGNED NOT NULL,
  item_id INT UNSIGNED NOT NULL,
  CONSTRAINT equipped_fk_characters
    FOREIGN KEY (character_id)
    REFERENCES characters (character_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT equipped_fk_items
    FOREIGN KEY (item_id)
    REFERENCES items (item_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE OR REPLACE VIEW character_items AS
  SELECT crctrs.character_id AS character_id, crctrs.name AS character_name, itms.name AS item_name, itms.armor AS armor, itms.damage AS damage
    FROM characters crctrs      
    INNER JOIN equipped equpd     
    ON crctrs.character_id=equpd.character_id
    INNER JOIN items itms
    ON itms.item_id=equpd.item_id
   UNION
    SELECT crctrs.character_id AS character_id, crctrs.name AS character_name, itms.name AS item_name, itms.armor AS armor, itms.damage AS damage
    FROM characters crctrs      
    INNER JOIN inventory invntry     
    ON crctrs.character_id=invntry.character_id
    INNER JOIN items itms
    ON itms.item_id=invntry.item_id
	ORDER BY items.name ASC;     
   
CREATE OR REPLACE VIEW team_items AS
  SELECT teams.team_id AS team_id, teams.name AS team_name, itms.name AS item_name, itms.armor AS armor, itms.damage AS damage
    FROM teams
    INNER JOIN team_members
    ON teams.team_id=team_members.team_id
    INNER JOIN characters
    ON team_members.character_id=characters.character_id
    INNER JOIN equipped equpd
    ON characters.character_id=equpd.character_id
    INNER JOIN items itms
    ON itms.item_id=equpd.item_id
   UNION
    SELECT teams.team_id AS team_id, teams.name AS team_name, itms.name AS item_name, itms.armor AS armor, itms.damage AS damage
    FROM teams
    INNER JOIN team_members
    ON teams.team_id=team_members.team_id
    INNER JOIN characters
    ON team_members.character_id=characters.character_id
    INNER JOIN inventory invntry     
    ON characters.character_id=invntry.character_id
    INNER JOIN items itms
    ON itms.item_id=invntry.item_id
	ORDER BY items.name ASC;     

DELIMITER ;;
CREATE FUNCTION armor_total(char_id INT UNSIGNED)
RETURNS INT UNSIGNED
BEGIN
	-- can't have negative armor
	DECLARE armor_total INT UNSIGNED;
  -- know I'm missing something to isolate equipped armor by each character but unsure what or where it'd go.
    SELECT SUM(character_stats.armor+items.armor) INTO armor_total
    FROM characters      
    INNER JOIN equipped
    ON characters.character_id=equipped.character_id
    INNER JOIN items
    ON items.item_id=equipped.item_id
    INNER JOIN character_stats     
    ON character_stats.character_id=characters.character_id;
    RETURN armor_total;
END;;
DELIMITER ;

CREATE TABLE cards (
  card_id varchar(100) NOT NULL DEFAULT '',
  story_id varchar(100) NOT NULL DEFAULT '',
  text varchar(2000) NOT NULL DEFAULT '',
  state varchar(20) NOT NULL DEFAULT '',
  PRIMARY KEY (card_id)
);

CREATE TABLE stories (
  story_id varchar(100) NOT NULL DEFAULT '',
  story_card varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (story_id,story_card)
);

CREATE TABLE rules (
  story_id varchar(100) NOT NULL DEFAULT '',
  card_id varchar(100) NOT NULL DEFAULT '',
  created timestamp NOT NULL,
  PRIMARY KEY (story_id,card_id)
);

CREATE TABLE examples (
  rule_card_id varchar(100) NOT NULL DEFAULT '',
  card_id varchar(100) NOT NULL DEFAULT '',
  created timestamp NOT NULL,
  PRIMARY KEY (rule_card_id,card_id)
);

CREATE TABLE questions (
  story_id varchar(100) NOT NULL DEFAULT '',
  card_id varchar(100) NOT NULL DEFAULT '',
  created timestamp NOT NULL,
  PRIMARY KEY (story_id,card_id)
);

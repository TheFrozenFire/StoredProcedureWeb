CREATE TABLE Config (
    name VARCHAR(255) NOT NULL,
    value VARCHAR(255),
    PRIMARY KEY (name)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ENGINE = InnoDB;
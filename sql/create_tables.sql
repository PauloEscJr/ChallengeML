-- -----------------------------------------------------
-- Schema MercadoLivreDB
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `MercadoLivreDB` DEFAULT CHARACTER SET utf8 ;
USE `MercadoLivreDB` ;

-- -----------------------------------------------------
-- Table `CUSTOMER`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CUSTOMER` (
  `customer_id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(100) NOT NULL,
  `last_name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(250) NOT NULL,
  `gender` CHAR(2) NULL,
  `address` VARCHAR(250) NULL,
  `birth_date` DATE NULL,
  `phone` VARCHAR(20) NULL,
  PRIMARY KEY (`customer_id`)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `CATEGORY`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CATEGORY` (
  `category_id` INT NOT NULL AUTO_INCREMENT,
  `category_name` VARCHAR(100) NOT NULL,
  `category_path` VARCHAR(250) NOT NULL,
  PRIMARY KEY (`category_id`)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ITEM`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ITEM` (
  `item_id` INT NOT NULL AUTO_INCREMENT,
  `category_id` INT NOT NULL,
  `seller_id` INT NOT NULL,
  `item_name` VARCHAR(250) NOT NULL,
  `description` VARCHAR(250) NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `status` VARCHAR(20) NOT NULL,
  `cancel_date` DATE NULL,
  PRIMARY KEY (`item_id`),
  INDEX `fk_Item_Category_idx` (`category_id` ASC),
  INDEX `fk_Item_Seller_idx` (`seller_id` ASC),
  CONSTRAINT `fk_item_category`
    FOREIGN KEY (`category_id`)
    REFERENCES `CATEGORY` (`category_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_item_seller`
    FOREIGN KEY (`seller_id`)
    REFERENCES `CUSTOMER` (`customer_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ORDER`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ORDER` (
  `order_id` INT NOT NULL AUTO_INCREMENT,
  `customer_id` INT NOT NULL,
  `item_id` INT NOT NULL,
  `quantity` INT NOT NULL,
  `total_price` DECIMAL(10,2) NOT NULL,
  `order_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_id`),
  INDEX `fk_Order_Customer_idx` (`customer_id` ASC),
  INDEX `fk_Order_Item_idx` (`item_id` ASC),
  CONSTRAINT `fk_Order_Customer`
    FOREIGN KEY (`customer_id`)
    REFERENCES `CUSTOMER` (`customer_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Order_Item`
    FOREIGN KEY (`item_id`)
    REFERENCES `ITEM` (`item_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ITEM_HISTORY`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ITEM_HISTORY` (
  `history_id` INT NOT NULL AUTO_INCREMENT,
  `item_id` INT NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `status` VARCHAR(20) NULL,
  `start_date` DATE NOT NULL,
  `end_date` DATE NOT NULL DEFAULT '2100-12-31',
  PRIMARY KEY (`history_id`),
  INDEX `fk_Item_History_Item_idx` (`item_id` ASC),
  CONSTRAINT `fk_Item_History_Item`
    FOREIGN KEY (`item_id`)
    REFERENCES `ITEM` (`item_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB;

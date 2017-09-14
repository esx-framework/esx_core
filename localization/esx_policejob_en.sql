INSERT INTO `addon_account` (name, label, shared) VALUES
  ('society_police','Police',1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
  ('society_police','Police',1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
  ('society_police', 'Police', 1)
;

INSERT INTO `jobs` (name, label) VALUES
  ('police','LSPD')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
  ('police',0,'recruit','Recruit',20,'{\"tshirt_1\":57,\"torso_1\":55,\"arms\":0,\"pants_1\":35,\"glasses\":0,\"decals_2\":0,\"hair_color_2\":0,\"helmet_2\":0,\"hair_color_1\":5,\"face\":19,\"glasses_2\":1,\"torso_2\":0,\"shoes\":24,\"hair_1\":2,\"skin\":34,\"sex\":0,\"glasses_1\":0,\"pants_2\":0,\"hair_2\":0,\"decals_1\":0,\"tshirt_2\":0,\"helmet_1\":8}','{\"tshirt_1\":34,\"torso_1\":48,\"shoes\":24,\"pants_1\":34,\"torso_2\":0,\"decals_2\":0,\"hair_color_2\":0,\"glasses\":0,\"helmet_2\":0,\"hair_2\":3,\"face\":21,\"decals_1\":0,\"glasses_2\":1,\"hair_1\":11,\"skin\":34,\"sex\":1,\"glasses_1\":5,\"pants_2\":0,\"arms\":14,\"hair_color_1\":10,\"tshirt_2\":0,\"helmet_1\":57}'),
  ('police',1,'sergeant','Sergeant',40,'{\"tshirt_1\":58,\"torso_1\":55,\"shoes\":24,\"pants_1\":35,\"pants_2\":0,\"decals_2\":1,\"hair_color_2\":0,\"face\":19,\"helmet_2\":0,\"hair_2\":0,\"arms\":0,\"decals_1\":8,\"torso_2\":0,\"hair_1\":2,\"skin\":34,\"sex\":0,\"glasses_1\":0,\"glasses_2\":1,\"hair_color_1\":5,\"glasses\":0,\"tshirt_2\":0,\"helmet_1\":11}','{\"tshirt_1\":35,\"torso_1\":48,\"arms\":14,\"pants_1\":34,\"pants_2\":0,\"decals_2\":1,\"hair_color_2\":0,\"shoes\":24,\"helmet_2\":0,\"hair_2\":3,\"decals_1\":7,\"torso_2\":0,\"face\":21,\"hair_1\":11,\"skin\":34,\"sex\":1,\"glasses_1\":5,\"glasses_2\":1,\"hair_color_1\":10,\"glasses\":0,\"tshirt_2\":0,\"helmet_1\":57}'),
  ('police',2,'lieutenant','Lieutenant',65,'{\"tshirt_1\":58,\"torso_1\":55,\"shoes\":24,\"pants_1\":35,\"pants_2\":0,\"decals_2\":2,\"hair_color_2\":0,\"face\":19,\"helmet_2\":0,\"hair_2\":0,\"glasses\":0,\"decals_1\":8,\"hair_color_1\":5,\"hair_1\":2,\"skin\":34,\"sex\":0,\"glasses_1\":0,\"glasses_2\":1,\"torso_2\":0,\"arms\":41,\"tshirt_2\":0,\"helmet_1\":11}','{\"tshirt_1\":35,\"torso_1\":48,\"arms\":44,\"pants_1\":34,\"hair_2\":3,\"decals_2\":2,\"hair_color_2\":0,\"hair_color_1\":10,\"helmet_2\":0,\"face\":21,\"shoes\":24,\"torso_2\":0,\"glasses_2\":1,\"hair_1\":11,\"skin\":34,\"sex\":1,\"glasses_1\":5,\"pants_2\":0,\"decals_1\":7,\"glasses\":0,\"tshirt_2\":0,\"helmet_1\":57}'),
  ('police',3,'boss','Chief',80,'{\"tshirt_1\":58,\"torso_1\":55,\"shoes\":24,\"pants_1\":35,\"pants_2\":0,\"decals_2\":3,\"hair_color_2\":0,\"face\":19,\"helmet_2\":0,\"hair_2\":0,\"arms\":41,\"torso_2\":0,\"hair_color_1\":5,\"hair_1\":2,\"skin\":34,\"sex\":0,\"glasses_1\":0,\"glasses_2\":1,\"decals_1\":8,\"glasses\":0,\"tshirt_2\":0,\"helmet_1\":11}','{\"tshirt_1\":35,\"torso_1\":48,\"arms\":44,\"pants_1\":34,\"pants_2\":0,\"decals_2\":3,\"hair_color_2\":0,\"face\":21,\"helmet_2\":0,\"hair_2\":3,\"decals_1\":7,\"torso_2\":0,\"hair_color_1\":10,\"hair_1\":11,\"skin\":34,\"sex\":1,\"glasses_1\":5,\"glasses_2\":1,\"shoes\":24,\"glasses\":0,\"tshirt_2\":0,\"helmet_1\":57}')
;

CREATE TABLE `fine_types` (

  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `category` int(11) DEFAULT NULL,

  PRIMARY KEY (`id`)
);

INSERT INTO `fine_types` (label, amount, category) VALUES
  ('Misuse of a horn', 30, 0),
  ('Illegally Crossing a continuous Line', 40, 0),
  ('Driving on the wrong side of the road', 250, 0),
  ('Illegal U-Turn', 250, 0),
  ('Illegally Driving Off-road', 170, 0),
  ('Refusing a Lawful Command', 30, 0),
  ('Illegally Stoped of a Vehicle', 150, 0),
  ('Illegal Parking', 70, 0),
  ('Failing to Yield to the right', 70, 0),
  ('Failure to comply with Vehicle Information', 90, 0),
  ('Failing to stop at a Stop Sign ', 105, 0),
  ('Failing to stop at a Red Light', 130, 0),
  ('Illegal Passing', 100, 0),
  ('Driving an illegal Vehicle', 100, 0),
  ('Driving without a License', 1500, 0),
  ('Hit and Run', 800, 0),
  ('Exceeding Speeds Over < 5 mph', 90, 0),
  ('Exceeding Speeds Over 5-15 mph', 120, 0),
  ('Exceeding Speeds Over 15-30 mph', 180, 0),
  ('Exceeding Speeds Over > 30 mph', 300, 0),
  ('Impeding traffic flow', 110, 1),
  ('Public Intoxication', 90, 1),
  ('Disorderly conduct', 90, 1),
  ('Obstruction of Justice', 130, 1),
  ('Insults towards Civilans', 75, 1),
  ('Disrespecting of an LEO', 110, 1),
  ('Verbal Threat towards a Civilan', 90, 1),
  ('Verbal Threat towards an LEO', 150, 1),
  ('Providing False Information', 250, 1),
  ('Attempt of Corruption', 1500, 1),
  ('Brandishing a weapon in city Limits', 120, 2),
  ('Brandishing a Lethal Weapon in city Limits', 300, 2),
  ('No Firearms License', 600, 2),
  ('Possession of an Illegal Weapon', 700, 2),
  ('Possession of Burglary Tools', 300, 2),
  ('Grand Theft Auto', 1800, 2),
  ('Intent to Sell/Distrube of an illegal Substance', 1500, 2),
  ('Frabrication of an Illegal Substance', 1500, 2),
  ('Possession of an Illegal Substance ', 650, 2),
  ('Kidnapping of a Civilan', 1500, 2),
  ('Kidnapping of an LEO', 2000, 2),
  ('Robbery', 650, 2),
  ('Armed Robbery of a Store', 650, 2),
  ('Armed Robbery of a Bank', 1500, 2),
  ('Assault on a Civilian', 2000, 3),
  ('Assault of an LEO', 2500, 3),
  ('Attempt of Murder of a Civilian', 3000, 3),
  ('Attempt of Murder of an LEO', 5000, 3),
  ('Murder of a Civilian', 10000, 3),
  ('Murder of an LEO', 30000, 3),
  ('Involuntary manslaughter', 1800, 3),
  ('Fraud', 2000, 2);
;

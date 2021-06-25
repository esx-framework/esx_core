USE `es_extended`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_police', '경찰', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_police', '경찰', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_police', '경찰', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('police', '경찰')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('police',0,'recruit','순경',20,'{}','{}'),
	('police',1,'officer','경장',40,'{}','{}'),
	('police',2,'sergeant','경사',60,'{}','{}'),
	('police',3,'lieutenant','경위',85,'{}','{}'),
	('police',4,'boss','경찰국장',100,'{}','{}')
;

CREATE TABLE `fine_types` (
	`id` int NOT NULL AUTO_INCREMENT,
	`label` varchar(255) DEFAULT NULL,
	`amount` int DEFAULT NULL,
	`category` int DEFAULT NULL,

	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO `fine_types` (label, amount, category) VALUES
	('경적 남용', 30, 0),
	('연속으로 라인을 넘음', 40, 0),
	('역주행', 250, 0),
	('불법 U턴', 250, 0),
	('불법적인 오프로드 운전', 170, 0),
	('공무원 명령 미준수', 30, 0),
	('불법적으로 차량 정지', 150, 0),
	('불법 주차', 70, 0),
	('오른쪽으로 양보하지 않음', 70, 0),
	('등록되지 않은 차량', 90, 0),
	('정지선 지키지 않음', 105, 0),
	('빨간불에서 멈추지 않음', 130, 0),
	('위험한 추월', 100, 0),
	('불법 차량 운전', 100, 0),
	('무면허 운전', 1500, 0),
	('뺑소니', 800, 0),
	('5 km 이상 과속', 90, 0),
	('5-15 km 과속', 120, 0),
	('15-30 km 과속', 180, 0),
	('30 km 이상 과속', 300, 0),
	('교통방해', 110, 1),
	('공공질서 문제', 90, 1),
	('무질서한 행동', 90, 1),
	('공무집행 방해', 130, 1),
	('민간인에 대한 모욕', 75, 1),
	('공무원에 대한 모욕', 110, 1),
	('민간인에 대한 언어폭력', 90, 1),
	('공무원에 대한 언어폭력', 150, 1),
	('허위 정보 제공', 250, 1),
	('부패 시도', 1500, 1),
	('도시에서 무기 사용', 120, 2),
	('도시에서 위험한 무기 사용', 300, 2),
	('총기 면허 없음', 600, 2),
	('불법 무기 소지', 700, 2),
	('절도 도구 소지', 300, 2),
	('차량 절도', 1800, 2),
	('마약 판매/분배', 1500, 2),
	('마약 제조', 1500, 2),
	('마약 소지 ', 650, 2),
	('민간인 납치', 1500, 2),
	('공무원 납치', 2000, 2),
	('강도', 650, 2),
	('상점의 무장 강도', 650, 2),
	('은행의 무장 강도', 1500, 2),
	('민간인에 대한 폭행', 2000, 3),
	('공무원에 대한 폭행', 2500, 3),
	('민간인 살인 시도', 3000, 3),
	('공무원 살인 시도', 5000, 3),
	('민간인 살인', 10000, 3),
	('공무원 살인', 30000, 3),
	('우발적 살인', 1800, 3),
	('사기', 2000, 2);
;

# fxserver-esx_joblisting
FR - Pôle Emploi

Update SQL database for job whitelist:

ALTER TABLE jobs add whitelisted BOOLEAN NOT NULL DEFAULT FALSE;

You can show (0) or hide (1) a job in the joblisting by changing the value in the DB of the field whitelisted

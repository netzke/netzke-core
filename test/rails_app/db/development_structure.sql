CREATE TABLE "netzke_preferences" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "key" varchar(255), "value" text, "user_id" integer, "role_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20100905214933');
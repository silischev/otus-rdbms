-- Триггеры и процедуры для логгирования информации --
CREATE TRIGGER log_views
  AFTER UPDATE OF views
  ON advertisements
  FOR ROW
EXECUTE PROCEDURE logAdsViewByUser();

CREATE OR REPLACE FUNCTION logAdsViewByUser() RETURNS TRIGGER AS
$$
BEGIN
  INSERT INTO advertisements_history(advertisement_id, action_id)
  VALUES (new.ID, (SELECT id FROM history_actions WHERE code = 'VIEW_ADS_BY_USER' LIMIT 1));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_user_toggle_delete_profile
  AFTER UPDATE OF deleted_at
  ON users
  FOR ROW
EXECUTE PROCEDURE logUserToggleDeleteProfile();

CREATE OR REPLACE FUNCTION logUserToggleDeleteProfile() RETURNS TRIGGER AS
$$
BEGIN
  IF (new.deleted_at IS NOT NULL) THEN
    INSERT INTO advertisements_history(advertisement_id, action_id, metadata)
    VALUES (new.ID, (SELECT id FROM history_actions WHERE code = 'USER_DEL_PROFILE' LIMIT 1),
            cast(concat('{"date" : "', CAST(NOW() AS TEXT), '"}') AS JSON));
  ELSE
    INSERT INTO advertisements_history(advertisement_id, action_id, metadata)
    VALUES (new.ID, (SELECT id FROM history_actions WHERE code = 'USER_RESTORE_PROFILE' LIMIT 1),
            cast(concat('{"date" : "', CAST(NOW() AS TEXT), '"}') AS JSON));
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
/*
  # Add Status Field to Charging Sessions

  1. Changes
    - Add `status` column to `charging_sessions` table
      - Values: 'active', 'completed'
      - Default: 'active' for ongoing charging sessions
      - NOT NULL to ensure every session has a status
    
  2. Purpose
    - Track whether a charging session is currently in progress or completed
    - Allow users to see active sessions after page reload
    - Enable resuming or completing sessions from any page

  3. Migration Safety
    - Uses IF NOT EXISTS pattern to prevent errors
    - Sets default value for existing rows
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'charging_sessions' AND column_name = 'status'
  ) THEN
    ALTER TABLE charging_sessions 
    ADD COLUMN status text NOT NULL DEFAULT 'completed'
    CHECK (status IN ('active', 'completed'));
  END IF;
END $$;

-- Update any existing rows to have 'completed' status
UPDATE charging_sessions SET status = 'completed' WHERE status IS NULL;

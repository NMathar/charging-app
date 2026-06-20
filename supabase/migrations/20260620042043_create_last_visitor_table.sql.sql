-- Create last_visitor table with a single entry that tracks the last visit
CREATE TABLE last_visitor (
  id INT PRIMARY KEY DEFAULT 1,
  last_visit TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (id = 1) -- Ensures only one row can exist
);

-- Insert the initial single row
INSERT INTO last_visitor (id) VALUES (1);

-- Enable RLS
ALTER TABLE last_visitor ENABLE ROW LEVEL SECURITY;

-- RLS policies: allow read and update for authenticated users
CREATE POLICY "select_last_visitor" ON last_visitor FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "update_last_visitor" ON last_visitor FOR UPDATE
  TO authenticated USING (true) WITH CHECK (true);

-- Create an index for faster updates
CREATE UNIQUE INDEX idx_last_visitor_id ON last_visitor (id);

-- Add comment
COMMENT ON TABLE last_visitor IS 'Tracks the last visitor - single row table';

/*
  # EV Charging Cost Calculator Schema

  1. New Tables
    - `settings`
      - `id` (uuid, primary key) - Unique identifier
      - `battery_capacity` (numeric) - Battery capacity in kWh
      - `electricity_price` (numeric) - Price per kWh in currency
      - `wallbox_power` (numeric) - Wallbox power in kW
      - `wallbox_loss` (numeric) - Wallbox loss percentage (0-100)
      - `created_at` (timestamptz) - Creation timestamp
      - `updated_at` (timestamptz) - Last update timestamp

    - `charging_sessions`
      - `id` (uuid, primary key) - Unique identifier
      - `start_percentage` (numeric) - Starting battery percentage (0-100)
      - `end_percentage` (numeric) - Ending battery percentage (0-100)
      - `start_time` (timestamptz, nullable) - Optional start time for timer-based charging
      - `end_time` (timestamptz, nullable) - Optional end time for timer-based charging
      - `battery_capacity` (numeric) - Battery capacity used for this session
      - `electricity_price` (numeric) - Electricity price used for this session
      - `wallbox_power` (numeric) - Wallbox power used for this session
      - `wallbox_loss` (numeric) - Wallbox loss used for this session
      - `energy_charged` (numeric) - Calculated energy charged in kWh
      - `total_cost` (numeric) - Calculated total cost
      - `created_at` (timestamptz) - Session creation timestamp

  2. Security
    - Enable RLS on both tables
    - Add public access policies (no authentication required for static site)

  3. Important Notes
    - This is designed for a static site without user authentication
    - All data is publicly accessible
    - Settings table will typically have one row for default values
    - Each charging session can override default settings
*/

CREATE TABLE IF NOT EXISTS settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  battery_capacity numeric NOT NULL DEFAULT 50,
  electricity_price numeric NOT NULL DEFAULT 0.30,
  wallbox_power numeric NOT NULL DEFAULT 11,
  wallbox_loss numeric NOT NULL DEFAULT 10,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS charging_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  start_percentage numeric NOT NULL CHECK (start_percentage >= 0 AND start_percentage <= 100),
  end_percentage numeric NOT NULL CHECK (end_percentage >= 0 AND end_percentage <= 100),
  start_time timestamptz,
  end_time timestamptz,
  battery_capacity numeric NOT NULL,
  electricity_price numeric NOT NULL,
  wallbox_power numeric NOT NULL,
  wallbox_loss numeric NOT NULL,
  energy_charged numeric NOT NULL,
  total_cost numeric NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE charging_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to settings"
  ON settings
  FOR SELECT
  TO anon
  USING (true);

CREATE POLICY "Allow public insert to settings"
  ON settings
  FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Allow public update to settings"
  ON settings
  FOR UPDATE
  TO anon
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow public delete from settings"
  ON settings
  FOR DELETE
  TO anon
  USING (true);

CREATE POLICY "Allow public read access to charging sessions"
  ON charging_sessions
  FOR SELECT
  TO anon
  USING (true);

CREATE POLICY "Allow public insert to charging sessions"
  ON charging_sessions
  FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Allow public update to charging sessions"
  ON charging_sessions
  FOR UPDATE
  TO anon
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow public delete from charging sessions"
  ON charging_sessions
  FOR DELETE
  TO anon
  USING (true);

INSERT INTO settings (battery_capacity, electricity_price, wallbox_power, wallbox_loss)
VALUES (50, 0.30, 11, 10)
ON CONFLICT DO NOTHING;

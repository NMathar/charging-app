export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      settings: {
        Row: {
          id: string
          battery_capacity: number
          electricity_price: number
          wallbox_power: number
          wallbox_loss: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          battery_capacity?: number
          electricity_price?: number
          wallbox_power?: number
          wallbox_loss?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          battery_capacity?: number
          electricity_price?: number
          wallbox_power?: number
          wallbox_loss?: number
          created_at?: string
          updated_at?: string
        }
        Relationships: []
      }
      charging_sessions: {
        Row: {
          id: string
          start_percentage: number
          end_percentage: number
          start_time: string | null
          end_time: string | null
          battery_capacity: number
          electricity_price: number
          wallbox_power: number
          wallbox_loss: number
          energy_charged: number
          total_cost: number
          status: string
          created_at: string
        }
        Insert: {
          id?: string
          start_percentage: number
          end_percentage: number
          start_time?: string | null
          end_time?: string | null
          battery_capacity: number
          electricity_price: number
          wallbox_power: number
          wallbox_loss: number
          energy_charged: number
          total_cost: number
          status?: string
          created_at?: string
        }
        Update: {
          id?: string
          start_percentage?: number
          end_percentage?: number
          start_time?: string | null
          end_time?: string | null
          battery_capacity?: number
          electricity_price?: number
          wallbox_power?: number
          wallbox_loss?: number
          energy_charged?: number
          total_cost?: number
          status?: string
          created_at?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

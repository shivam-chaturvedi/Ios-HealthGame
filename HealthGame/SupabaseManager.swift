import Foundation
import Supabase

/// Central place to initialize and share the Supabase client.
final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://wfzvidctvjvzggsbbcke.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmenZpZGN0dmp2emdnc2JiY2tlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQyMjEwNTUsImV4cCI6MjA3OTc5NzA1NX0.1ABFpOS3rztCdhmDCJp2LjJITsCVdpJvX_DoGD3EKY0"
        )
    }
}

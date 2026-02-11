import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 200, headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      throw new Error("No authorization header");
    }

    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: userError } = await supabaseClient.auth.getUser(token);

    if (userError || !user) {
      throw new Error("Unauthorized");
    }

    const { action, name } = await req.json();

    if (!action || !name) {
      throw new Error("Missing required fields: action and name");
    }

    const userType = action === "addPatientRole" ? "patient" : action === "addProfessionalRole" ? "professional" : action === "addAgentRole" ? "agent" : null;

    if (!userType) {
      throw new Error("Invalid action");
    }

    // Check if user already has a role
    const currentMetadata = user.app_metadata?.user_type;
    if (currentMetadata && currentMetadata !== "none") {
      throw new Error("User already has a role assigned");
    }

    // Update user metadata
    const { error: updateError } = await supabaseClient.auth.admin.updateUserById(
      user.id,
      {
        app_metadata: { user_type: userType },
      }
    );

    if (updateError) {
      throw updateError;
    }

    // Create profile based on user type
    if (userType === "patient") {
      const { error: profileError } = await supabaseClient
        .from("patient_profiles")
        .insert({
          id: user.id,
          email: user.email,
          name: name,
        });

      if (profileError) throw profileError;
    } else if (userType === "professional") {
      const { error: profileError } = await supabaseClient
        .from("professional_profiles")
        .insert({
          id: user.id,
          email: user.email,
          name: name,
        });

      if (profileError) throw profileError;
    }

    return new Response(
      JSON.stringify({ success: true }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, message: error.message }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      },
    );
  }
});
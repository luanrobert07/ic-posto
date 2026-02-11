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
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      {
        global: {
          headers: { Authorization: req.headers.get("Authorization")! },
        },
      }
    );

    const { data: { user }, error: userError } = await supabaseClient.auth.getUser();
    if (userError || !user) {
      throw new Error("Unauthorized");
    }

    const { action, ...data } = await req.json();

    let result;

    switch (action) {
      case "getPatientFromId": {
        const userType = user.app_metadata?.user_type;
        if (userType !== "professional") {
          throw new Error("Only professionals can view patients");
        }

        const { patientId } = data;
        if (!patientId) {
          throw new Error("Missing patientId");
        }

        const { data: patient, error } = await supabaseClient
          .from("patient_profiles")
          .select("id, name, phone")
          .eq("id", patientId)
          .single();

        if (error) throw error;

        result = { success: true, ...patient };
        break;
      }

      case "updatePatientProfile": {
        const userType = user.app_metadata?.user_type;
        if (userType !== "patient") {
          throw new Error("Only patients can update their profile");
        }

        const updateData: any = {};
        
        if (data.phone !== undefined) updateData.phone = data.phone;
        if (data.name !== undefined) updateData.name = data.name;
        if (data.cpf !== undefined) updateData.cpf = data.cpf;
        if (data.birth_date !== undefined) updateData.birth_date = data.birth_date;

        if (Object.keys(updateData).length > 0) {
          updateData.updated_at = new Date().toISOString();
          
          const { error } = await supabaseClient
            .from("patient_profiles")
            .update(updateData)
            .eq("id", user.id);

          if (error) throw error;
        }

        result = { success: true };
        break;
      }

      default:
        throw new Error("Invalid action");
    }

    return new Response(
      JSON.stringify(result),
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
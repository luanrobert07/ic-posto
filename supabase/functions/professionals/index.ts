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
      case "searchProfessionals": {
        const userType = user.app_metadata?.user_type;
        if (userType !== "patient") {
          throw new Error("Only patients can search professionals");
        }

        const startAfter = data.startAfter || null;
        const limit = 10;

        let query = supabaseClient
          .from("professional_profiles")
          .select("id, name, specialty, bio, schedule_start, schedule_end, appointment_duration")
          .order("id")
          .limit(limit);

        if (startAfter) {
          query = query.gt("id", startAfter);
        }

        const { data: professionals, error } = await query;
        if (error) throw error;

        const lastDocId = professionals.length > 0 ? professionals[professionals.length - 1].id : null;
        const canLoadMore = professionals.length === limit;

        result = {
          success: true,
          professionals,
          lastDocId,
          canLoadMore,
        };
        break;
      }

      case "getProfessionalFromId": {
        const userType = user.app_metadata?.user_type;
        if (userType !== "patient") {
          throw new Error("Only patients can view professionals");
        }

        const { professionalId } = data;
        if (!professionalId) {
          throw new Error("Missing professionalId");
        }

        const { data: professional, error } = await supabaseClient
          .from("professional_profiles")
          .select("id, name, specialty, bio, schedule_start, schedule_end, appointment_duration")
          .eq("id", professionalId)
          .single();

        if (error) throw error;

        result = { success: true, ...professional };
        break;
      }

      case "updateProfessionalProfile": {
        const userType = user.app_metadata?.user_type;
        if (userType !== "professional") {
          throw new Error("Only professionals can update their profile");
        }

        const updateData: any = {};
        
        if (data.phone !== undefined) updateData.phone = data.phone;
        if (data.specialty !== undefined) updateData.specialty = data.specialty;
        if (data.bio !== undefined) updateData.bio = data.bio;
        if (data.schedule_start !== undefined) updateData.schedule_start = data.schedule_start;
        if (data.schedule_end !== undefined) updateData.schedule_end = data.schedule_end;
        if (data.appointment_duration !== undefined) updateData.appointment_duration = data.appointment_duration;

        if (Object.keys(updateData).length > 0) {
          updateData.updated_at = new Date().toISOString();
          
          const { error } = await supabaseClient
            .from("professional_profiles")
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
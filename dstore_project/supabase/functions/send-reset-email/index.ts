import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')

serve(async (req) => {
  // Gérer CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      }
    })
  }

  try {
    const { email, code } = await req.json()

    // Valider les données
    if (!email || !code) {
      return new Response(
        JSON.stringify({ error: 'Email et code requis' }),
        { 
          status: 400,
          headers: { 
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
          }
        }
      )
    }

    // Envoyer l'email avec Resend (service gratuit)
    const emailResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'DSTORE <noreply@yourdomain.com>', // Remplacez par votre domaine
        to: [email],
        subject: 'Code de récupération - DSTORE',
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #333;">Code de récupération DSTORE</h2>
            <p>Bonjour,</p>
            <p>Votre code de récupération de mot de passe est :</p>
            <div style="background: #f5f5f5; padding: 20px; text-align: center; margin: 20px 0;">
              <h1 style="color: #007bff; font-size: 32px; margin: 0;">${code}</h1>
            </div>
            <p><strong>Ce code expire dans 1 minute.</strong></p>
            <p>Si vous n'avez pas demandé cette récupération, ignorez cet email.</p>
            <hr style="margin: 30px 0;">
            <p style="color: #666; font-size: 14px;">
              Cordialement,<br>
              L'équipe DSTORE Support
            </p>
          </div>
        `,
      }),
    })

    if (!emailResponse.ok) {
      const error = await emailResponse.text()
      console.error('Erreur Resend:', error)
      throw new Error(`Erreur envoi email: ${error}`)
    }

    const result = await emailResponse.json()
    console.log('Email envoyé avec succès:', result)

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Email envoyé avec succès',
        id: result.id 
      }),
      { 
        status: 200,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
      }
    )

  } catch (error) {
    console.error('Erreur:', error)
    return new Response(
      JSON.stringify({ 
        error: 'Erreur lors de l\'envoi de l\'email',
        details: error.message 
      }),
      { 
        status: 500,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
      }
    )
  }
})

// Fonction Edge Supabase pour envoyer un email avec code de vérification
// À déployer dans Supabase Edge Functions

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Gérer les requêtes OPTIONS pour CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { to, code } = await req.json()

    // Valider les paramètres
    if (!to || !code) {
      return new Response(
        JSON.stringify({ error: 'Email et code requis' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Configuration de l'email (vous pouvez utiliser Resend, SendGrid, etc.)
    const emailData = {
      from: 'noreply@votre-app.com',
      to: [to],
      subject: 'Code de vérification - Réinitialisation de mot de passe',
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <title>Code de vérification</title>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { text-align: center; margin-bottom: 30px; }
            .code-box { 
              background-color: #f8f9fa; 
              border: 2px solid #2196F3; 
              border-radius: 8px; 
              padding: 20px; 
              text-align: center; 
              margin: 20px 0; 
            }
            .code { 
              font-size: 32px; 
              font-weight: bold; 
              color: #2196F3; 
              letter-spacing: 5px; 
              margin: 10px 0; 
            }
            .footer { margin-top: 30px; font-size: 14px; color: #666; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1 style="color: #2196F3;">Code de vérification</h1>
            </div>
            
            <p>Bonjour,</p>
            
            <p>Vous avez demandé la réinitialisation de votre mot de passe.</p>
            
            <div class="code-box">
              <p style="margin: 0; font-size: 16px;">Votre code de vérification :</p>
              <div class="code">${code}</div>
              <p style="margin: 0; color: #ff9800; font-weight: bold;">⏰ Ce code expire dans 2 minutes</p>
            </div>
            
            <p>Saisissez ce code dans l'application pour continuer la réinitialisation de votre mot de passe.</p>
            
            <div class="footer">
              <p><strong>Important :</strong></p>
              <ul>
                <li>Ce code est valable pendant 2 minutes seulement</li>
                <li>Ne partagez jamais ce code avec personne</li>
                <li>Si vous n'avez pas demandé cette réinitialisation, ignorez cet email</li>
              </ul>
              
              <p>Cordialement,<br>L'équipe Support</p>
            </div>
          </div>
        </body>
        </html>
      `,
      text: `
Code de vérification: ${code}

Vous avez demandé la réinitialisation de votre mot de passe.
Saisissez ce code dans l'application pour continuer.

Ce code expire dans 2 minutes.

Si vous n'avez pas demandé cette réinitialisation, ignorez cet email.
      `
    }

    // Ici vous pouvez utiliser votre service d'email préféré
    // Exemple avec Resend (nécessite une clé API)
    /*
    const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')
    
    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify(emailData),
    })
    
    const result = await response.json()
    */

    // Pour le moment, on simule l'envoi
    console.log('📧 Email simulé envoyé à:', to)
    console.log('🔢 Code:', code)
    console.log('📄 Contenu:', emailData.text)

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Email envoyé avec succès',
        debug: {
          to,
          code,
          subject: emailData.subject
        }
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
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
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

/* 
Instructions pour déployer cette fonction :

1. Installer Supabase CLI :
   npm install -g supabase

2. Se connecter à votre projet :
   supabase login
   supabase link --project-ref pzbemsyremoypwnkxqew

3. Créer la fonction :
   supabase functions new send-verification-code

4. Copier ce code dans :
   supabase/functions/send-verification-code/index.ts

5. Déployer :
   supabase functions deploy send-verification-code

6. Configurer les variables d'environnement si nécessaire :
   supabase secrets set RESEND_API_KEY=your_api_key
*/

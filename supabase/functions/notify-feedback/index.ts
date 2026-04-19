import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')

serve(async (req) => {
  // Webhooks send the data in a 'record' object
  const { record } = await req.json()

  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${RESEND_API_KEY}`,
    },
    body: JSON.stringify({
      from: 'Studio 10200 <notifications@studio10200.dev>',
      to: ['studio10200@gmail.com'], // The email where you want to receive the alerts
      subject: `New Feedback: ${record.project_name || 'General'}`,
      html: `
        <div style="font-family: sans-serif; color: #333;">
          <h2>New Feedback Received</h2>
          <p><strong>Project:</strong> ${record.project_name || 'N/A'}</p>
          <p><strong>Message:</strong></p>
          <blockquote style="background: #f4f4f4; padding: 15px; border-left: 5px solid #673AB7;">
            ${record.message}
          </blockquote>
          <p><strong>Contact:</strong> ${record.contact_email || 'Not provided'}</p>
          <hr />
          <p style="font-size: 0.8em; color: #666;">Sent via Studio 10200 Webhook</p>
        </div>
      `,
    }),
  })

  const data = await res.json()

  return new Response(JSON.stringify(data), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  })
})
const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST,
  port: process.env.EMAIL_PORT,
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  }
});

const sendOTPEmail = async (email, fullName, otp) => {
  await transporter.sendMail({
    from: `"Household Services" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: 'Your Verification OTP',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 500px; margin: auto;">
        <h2 style="color: #4F46E5;">Household Services</h2>
        <p>Hello <strong>${fullName}</strong>,</p>
        <p>Your OTP verification code is:</p>
        <div style="font-size: 36px; font-weight: bold; color: #4F46E5; letter-spacing: 8px; margin: 20px 0;">
          ${otp}
        </div>
        <p>This code expires in <strong>10 minutes</strong>.</p>
        <p>If you did not request this, please ignore this email.</p>
      </div>
    `
  });
};

module.exports = { sendOTPEmail };
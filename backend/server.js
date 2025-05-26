const express = require('express');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

// Mock database: account balances and pins
const accounts = {
  "610747616": { pin: "4596", balance: 10.0 }, // payer
  "RECEIVER": { balance: 0.0 } // receiver account
};

// Payment API endpoint
app.post('/api/payment', (req, res) => {
  const { accountNo, pin, referenceId, amount, currency, description } = req.body;

  if (!accountNo || !pin || !amount || !referenceId) {
    return res.status(400).json({ success: false, message: 'Missing required payment fields' });
  }

  const payerAccount = accounts[accountNo];
  if (!payerAccount) {
    return res.status(400).json({ success: false, message: 'Invalid account number' });
  }

  if (payerAccount.pin !== pin) {
    return res.status(401).json({ success: false, message: 'Invalid PIN' });
  }

  if (payerAccount.balance < amount) {
    return res.status(402).json({ success: false, message: 'Insufficient funds' });
  }

  // Deduct from payer
  payerAccount.balance -= amount;
  // Credit receiver
  accounts['RECEIVER'].balance += amount;

  return res.json({
    success: true,
    message: 'Payment Successful',
    transactionId: `TXN-${Date.now()}`
  });
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Mock payment server running on http://localhost:${PORT}`);
});
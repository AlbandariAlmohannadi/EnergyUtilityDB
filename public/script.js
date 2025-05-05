// Fetch Meter IDs from Backend API
async function populateMeterIds() {
    const meterSelect = document.getElementById('meterId');
    meterSelect.innerHTML = '<option value="">Loading meters...</option>';

    try {
        const response = await fetch('http://localhost:3000/api/meters');
        
        if (!response.ok) {
            throw new Error('Failed to load meters');
        }

        const meters = await response.json();
        meterSelect.innerHTML = '<option value="">Select Meter ID</option>';

        meters.forEach(meter => {
            const option = document.createElement('option');
            option.value = meter.MeterID;
            option.textContent = `Meter ${meter.MeterID} (${meter.Type})`;
            meterSelect.appendChild(option);
        });

    } catch (error) {
        console.error('Error:', error);
        meterSelect.innerHTML = '<option value="">Error loading meters</option>';
        showError('meterError', 'Failed to load meters. Try refreshing.');
    }
}

// Form Submission Handler
document.getElementById('readingForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    clearErrors();

    const meterId = document.getElementById('meterId').value;
    const date = document.getElementById('date').value;
    const value = parseFloat(document.getElementById('value').value);

    // Validation
    let isValid = true;
    if (!meterId) {
        showError('meterError', 'Please select a Meter ID.');
        isValid = false;
    }
    if (!date || new Date(date) > new Date()) {
        showError('dateError', 'Date cannot be in the future.');
        isValid = false;
    }
    if (isNaN(value) || value <= 0) {
        showError('valueError', 'Value must be greater than 0.');
        isValid = false;
    }

    if (!isValid) return;

    try {
        const response = await fetch('http://localhost:3000/api/readings', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ meterId, date, value })
        });

        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.error || 'Failed to save reading');
        }

        alert('Reading submitted successfully!');
        resetForm();

    } catch (error) {
        console.error('Submission error:', error);
        alert(`Error: ${error.message}`);
    }
});

// Helper Functions
function showError(elementId, message) {
    document.getElementById(elementId).textContent = message;
}

function clearErrors() {
    document.querySelectorAll('.error').forEach(el => el.textContent = '');
}

function resetForm() {
    document.getElementById('readingForm').reset();
    clearErrors();
}

// Initialize on Page Load
window.onload = populateMeterIds;
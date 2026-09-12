async function checkWeather() {

    const city = document.getElementById("city").value.trim();

    const url =
        city === ""
        ? "https://vpjyx0edm8.execute-api.us-east-1.amazonaws.com/weather"
        : `https://vpjyx0edm8.execute-api.us-east-1.amazonaws.com/weather?city=${encodeURIComponent(city)}`;

    try {

        const response = await fetch(url);

        const data = await response.json();

        document.getElementById("cityName").innerText = data.city;
        document.getElementById("temp").innerText = data.temperature + " °C";
        document.getElementById("humidity").innerText = data.humidity + " %";
        document.getElementById("weather").innerText = data.weather;
        document.getElementById("advice").innerText = data.watering_advice;

    }
    catch(error){

        alert("Unable to connect to the API.");

        console.error(error);

    }

}
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تطبيق الصلاة والقرآن الكريم</title>
    <style>
        * {
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
        }

        body {
            background-color: #f4f7f6;
            color: #333;
            padding: 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .container {
            width: 100%;
            max-width: 600px;
            background: #ffffff;
            border-radius: 15px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
            overflow: hidden;
            margin-bottom: 20px;
        }

        .header {
            background: linear-gradient(135deg, #11998e, #38ef7d);
            color: white;
            padding: 25px;
            text-align: center;
        }

        .header h1 {
            font-size: 24px;
            margin-bottom: 5px;
        }

        .location-info {
            font-size: 14px;
            opacity: 0.9;
        }

        .prayers-list {
            padding: 20px;
        }

        .prayer-card {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 20px;
            margin-bottom: 10px;
            background: #f9f9f9;
            border-radius: 8px;
            border-right: 4px solid #11998e;
            transition: 0.3s;
        }

        .prayer-card.active {
            background: #e8f8f5;
            border-right-color: #38ef7d;
            font-weight: bold;
        }

        .quran-section {
            padding: 20px;
            border-top: 1px solid #eee;
        }

        .quran-section h2 {
            font-size: 18px;
            margin-bottom: 15px;
            color: #11998e;
        }

        select {
            width: 100%;
            padding: 10px;
            border-radius: 8px;
            border: 1px solid #ccc;
            margin-bottom: 15px;
            font-size: 16px;
        }

        audio {
            width: 100%;
            margin-top: 10px;
        }

        .btn {
            background: #11998e;
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 8px;
            cursor: pointer;
            width: 100%;
            font-size: 16px;
        }

        .btn:hover {
            background: #0e8076;
        }
    </style>
</head>
<body>

    <div class="container">
        <!-- قسم أوقات الصلاة -->
        <div class="header">
            <h1>مواقيت الصلاة</h1>
            <div class="location-info" id="location">جاري تحديد الموقع...</div>
        </div>

        <div class="prayers-list" id="prayersContainer">
            <div class="prayer-card"><span>الفجر</span><span id="Fajr">--:--</span></div>
            <div class="prayer-card"><span>الشروق</span><span id="Sunrise">--:--</span></div>
            <div class="prayer-card"><span>الظهر</span><span id="Dhuhr">--:--</span></div>
            <div class="prayer-card"><span>العصر</span><span id="Asr">--:--</span></div>
            <div class="prayer-card"><span>المغرب</span><span id="Maghrib">--:--</span></div>
            <div class="prayer-card"><span>العشاء</span><span id="Isha">--:--</span></div>
        </div>

        <!-- قسم الاستماع للأذان -->
        <div class="quran-section">
            <h2>سماع الأذان</h2>
            <audio id="adhanAudio" controls>
                <source src="https://www.islamcan.com/common/makkah.mp3" type="audio/mpeg">
                متصفحك لا يدعم مشغل الصوت.
            </audio>
        </div>

        <!-- قسم القرآن الكريم -->
        <div class="quran-section">
            <h2>القرآن الكريم (صوتي)</h2>
            <select id="surahSelect">
                <option value="">اختر السورة...</option>
            </select>
            <audio id="quranAudio" controls>
                متصفحك لا يدعم مشغل الصوت.
            </audio>
        </div>
    </div>

    <script>
        // 1. جلب أوقات الصلاة بحسب موقع المستخدم
        function getPrayerTimes() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(position => {
                    const lat = position.coords.latitude;
                    const lng = position.coords.longitude;
                    
                    document.getElementById('location').innerText = `إحداثياتك: ${lat.toFixed(2)}, ${lng.toFixed(2)}`;

                    fetch(`https://api.aladhan.com/v1/timings?latitude=${lat}&longitude=${lng}&method=5`)
                        .then(response => response.json())
                        .then(data => {
                            const timings = data.data.timings;
                            document.getElementById('Fajr').innerText = timings.Fajr;
                            document.getElementById('Sunrise').innerText = timings.Sunrise;
                            document.getElementById('Dhuhr').innerText = timings.Dhuhr;
                            document.getElementById('Asr').innerText = timings.Asr;
                            document.getElementById('Maghrib').innerText = timings.Maghrib;
                            document.getElementById('Isha').innerText = timings.Isha;
                        })
                        .catch(err => alert("حدث خطأ أثناء جلب أوقات الصلاة"));
                }, () => {
                    document.getElementById('location').innerText = "تم إيقاف تحديد الموقع (يتم عرض أوقات افتراضية لمدينة مكة)";
                    fetchPrayerForCity("Makkah", "Saudi Arabia");
                });
            } else {
                fetchPrayerForCity("Makkah", "Saudi Arabia");
            }
        }

        // جلب الأوقات لمدينة معينة في حال رفض الإذن للموقع
        function fetchPrayerForCity(city, country) {
            fetch(`https://api.aladhan.com/v1/timingsByCity?city=${city}&country=${country}&method=5`)
                .then(res => res.json())
                .then(data => {
                    const timings = data.data.timings;
                    for (let prayer in timings) {
                        if (document.getElementById(prayer)) {
                            document.getElementById(prayer).innerText = timings[prayer];
                        }
                    }
                });
        }

        // 2. تحميل قائمة سور القرآن الكريم
        function loadQuranSurahs() {
            fetch('https://api.alquran.cloud/v1/surah')
                .then(res => res.json())
                .then(data => {
                    const surahSelect = document.getElementById('surahSelect');
                    data.data.forEach(surah => {
                        let option = document.createElement('option');
                        option.value = surah.number;
                        option.text = `${surah.number}. ${surah.name} (${surah.englishName})`;
                        surahSelect.appendChild(option);
                    });
                });
            
            // عند تغيير السورة، يتم جلب الملف الصوتي (بصوت القارئ مشاري العفاسي)
            document.getElementById('surahSelect').addEventListener('change', function() {
                const surahNum = this.value;
                if (surahNum) {
                    const quranAudio = document.getElementById('quranAudio');
                    // جلب التلاوة برقم السورة
                    quranAudio.src = `https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/${surahNum}.mp3`;
                    quranAudio.play();
                }
            });
        }

        // تشغيل الوظائف عند فتح الصفحة
        window.onload = () => {
            getPrayerTimes();
            loadQuranSurahs();
        };
    </script>
</body>
</html>
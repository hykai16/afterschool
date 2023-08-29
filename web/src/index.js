//SDKについてたやつ。どうすんの？？とりあえずhtmlにリンクも貼ってない。


// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyBnolo-09fEKfR7Nc0nnjPMxBOIHjQK6sg",
  authDomain: "afterschool-c2b8e.firebaseapp.com",
  projectId: "afterschool-c2b8e",
  storageBucket: "afterschool-c2b8e.appspot.com",
  messagingSenderId: "886864504275",
  appId: "1:886864504275:web:d8246f38025b743f78bb26",
  measurementId: "G-PLSWJMTLCD"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
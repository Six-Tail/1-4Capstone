const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
admin.initializeApp();

exports.kakaoLogin = functions.https.onRequest(async (req, res) => {
  const accessToken = req.body.accessToken;

  if (!accessToken) {
    console.error("Access token이 제공되지 않았습니다.");
    return res.status(400).send({message: "Access token이 필요합니다."});
  }

  try {
    const kakaoUserInfo = await axios.get("https://kapi.kakao.com/v2/user/me", {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    });

    console.log("Kakao User Info:", kakaoUserInfo.data);

    const uid = `kakao:${kakaoUserInfo.data.id}`;
    const additionalClaims = {
      name: kakaoUserInfo.data.properties.nickname,
      profile_picture: kakaoUserInfo.data.properties.profile_image,
    };

    const firebaseToken = await admin
        .auth()
        .createCustomToken(uid, additionalClaims)
        .catch((error) => {
          console.error("Firebase Token Creation Error:", error);
          throw new Error("Firebase 토큰 생성에 실패했습니다.");
        });

    console.log("Firebase Token:", firebaseToken);
    res.status(200).send({firebaseToken});
  } catch (error) {
    console.error("Kakao 인증에 실패했습니다.", error);
    res.status(500).send({
      message: "Kakao 인증에 실패했습니다.",
      error: error.message || error,
    });
  }
});

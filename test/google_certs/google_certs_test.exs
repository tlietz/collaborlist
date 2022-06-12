defmodule GoogleCertsTest do
  use ExUnit.Case, async: true

  @example_res %HTTPoison.Response{
    body:
      "{\n  \"fcbd7f481a825d113e0d03dd94e60b69ff1665a2\": \"-----BEGIN CERTIFICATE-----\\nMIIDJzCCAg+gAwIBAgIJAJCNvVzIrySKMA0GCSqGSIb3DQEBBQUAMDYxNDAyBgNV\\nBAMMK2ZlZGVyYXRlZC1zaWdub24uc3lzdGVtLmdzZXJ2aWNlYWNjb3VudC5jb20w\\nHhcNMjIwNDI5MTUyMTUxWhcNMjIwNTE2MDMzNjUxWjA2MTQwMgYDVQQDDCtmZWRl\\ncmF0ZWQtc2lnbm9uLnN5c3RlbS5nc2VydmljZWFjY291bnQuY29tMIIBIjANBgkq\\nhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoz7Gb9oYt/sq8Z37LDAcfSqQBuTtD669\\n+tjg+/hTVyXPRslIg6qPPLlVthRkXZYjhwnc85CXO9TW1C1ItJjX70vSQPvQ1wAL\\nWMOd306BPIYRkkKSa3APtidaM6ZmR2HosWRUf/03luhfkk9QUyVaCP2WJTFxENuJ\\ni5yyggE0cDT7MJGqn9VvYCv/+LUjiQ4v8jvc+dH881HeBDtwpsucXGCmx4ZcjEBc\\nrNXqJiQHPo1I3OIXxxtsLxujU8f0QVRjdSQDr8KgeSdic8kk4iJp8DISWSU1hQSC\\nbXUCG465L6I1iytO6iNQp+rfjpBt9jx0TA6VqIteglWhu5gfcKb9YQIDAQABozgw\\nNjAMBgNVHRMBAf8EAjAAMA4GA1UdDwEB/wQEAwIHgDAWBgNVHSUBAf8EDDAKBggr\\nBgEFBQcDAjANBgkqhkiG9w0BAQUFAAOCAQEAANlfZ6OYj/Wy951dSx7f7xxmleeW\\neDPhWqpL4J+8ljHB2HRbBi5EjdJInHNquL/wCDw46nJhTIQ13dh7YJhJhgLarLcq\\nd6DcBMeFTBZUFBoaHZNy7hZxZ1ggvonHGTpzPw68wW0Cx5erfswstwE7QPYBEHJf\\nOlj6zwNQgvSEC8rEMIKfVuB9g0OWdzduPnwyoGOhDixP9pAjlV0MfYc/rMUGGpKw\\npdg4kTBkx9XLYfiCfQJmsVz5CyQV9Q0VfdeIp5qKYWRutIQGTYPc0M0bgDSNpbRD\\nd/QbikaqP5Q54ag8wdyr4SPiGIKlWkQRfAYcdVqFOI/uGLqsGbaNCAl7bg==\\n-----END CERTIFICATE-----\\n\",\n  \"861649e450315383f6b9d510b7cd4e9226c3cd88\": \"-----BEGIN CERTIFICATE-----\\nMIIDJzCCAg+gAwIBAgIJANCP0rP/R41vMA0GCSqGSIb3DQEBBQUAMDYxNDAyBgNV\\nBAMMK2ZlZGVyYXRlZC1zaWdub24uc3lzdGVtLmdzZXJ2aWNlYWNjb3VudC5jb20w\\nHhcNMjIwNDIxMTUyMTUwWhcNMjIwNTA4MDMzNjUwWjA2MTQwMgYDVQQDDCtmZWRl\\ncmF0ZWQtc2lnbm9uLnN5c3RlbS5nc2VydmljZWFjY291bnQuY29tMIIBIjANBgkq\\nhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqR7fa5Gb2rhy+RJCJwSFn7J2KiKs/WgM\\nXVR+23Z6OfX89/utHGkM+Qk27abDGPXa0u9OKzwOU2JZx7yNye7LH4kKX1PEAEz0\\np9XGbfF3yFyiD5JkziOfQyYj9ERKWfxKatpk+oi9D/p2leQKzTfEZWIfLVZkgNXF\\nkUdhzCG68j5kFhZ1Ys9bRRDo3Q1BkLXmP/Y6PW1g74/rvAYCiQ6hJVvyyXYnqHco\\nawedgO6/MQihaSeAW25AhY8MXVo4+MdNvboahOlJg280YuxkCZiRqxyQEqd5HKCP\\nzP49TDQbdAxDa900ewCQK9gkbHiNKFbOBv/b94YfMh93NUoEa+jCnwIDAQABozgw\\nNjAMBgNVHRMBAf8EAjAAMA4GA1UdDwEB/wQEAwIHgDAWBgNVHSUBAf8EDDAKBggr\\nBgEFBQcDAjANBgkqhkiG9w0BAQUFAAOCAQEAY2ficho0B/tfCt2QtQPEYVQ6FPfa\\nuw8IhQHA12RgRcTLKNOhe9wYH4gYzCYbs08N/nX0UuoCI0ND1TgoUZT2BV9qY/Q3\\nztSCGHU0SeHore1u/vQVf5qpoeZapWohCXE/tMJP3nKkDfXyZHfTfo1wMQqprR8W\\nc3ZWH/jG49MBGURIkrmuP3AjjfXIK0tNcrUofWU/z2eXNIUTBxwE/Lgk8Ieb11j3\\nTjM9v0b2KqBOLcaZ0+0JuYRawC2EkdEOlhprF8ssREun3Syjx6bJA9g4NgMWveZ9\\nWQGthW7MggT5erMS/03e+h04FtaEaRygwtIUj0nGir2p0HqQ9FQDUnflHg==\\n-----END CERTIFICATE-----\\n\"\n}\n",
    headers: [
      {"Vary", "X-Origin"},
      {"Vary", "Referer"},
      {"Server", "scaffolding on HTTPServer2"},
      {"X-XSS-Protection", "0"},
      {"X-Frame-Options", "SAMEORIGIN"},
      {"X-Content-Type-Options", "nosniff"},
      {"Date", "Sat, 07 May 2022 02:09:04 GMT"},
      {"Expires", "Sat, 07 May 2022 08:56:14 GMT"},
      {"Cache-Control", "public, max-age=24430, must-revalidate, no-transform"},
      {"Content-Type", "application/json; charset=UTF-8"},
      {"Age", "45"},
      {"Alt-Svc",
       "h3=\":443\"; ma=2592000,h3-29=\":443\"; ma=2592000,h3-Q050=\":443\"; ma=2592000,h3-Q046=\":443\"; ma=2592000,h3-Q043=\":443\"; ma=2592000,quic=\":443\"; ma=2592000; v=\"46,43\""},
      {"Accept-Ranges", "none"},
      {"Vary", "Origin,Accept-Encoding"},
      {"Transfer-Encoding", "chunked"}
    ],
    request: %HTTPoison.Request{
      body: "",
      headers: [],
      method: :get,
      options: [],
      params: %{},
      url: "https://www.googleapis.com/oauth2/v1/certs"
    },
    request_url: "https://www.googleapis.com/oauth2/v1/certs",
    status_code: 200
  }

  describe "client_functions" do
    test "jwk_from_ets/2 works as expected" do
      sample_ets_lookup = [
        {"jwks",
         %{
           "b1a8259eb07660ef23781c85b7849bfa0a1c806c" => %JOSE.JWK{
             fields: %{},
             keys: :undefined,
             kty:
               {:jose_jwk_kty_rsa,
                {:RSAPublicKey,
                 25_443_445_131_005_887_349_079_870_099_345_462_942_197_254_525_224_813_836_357_390_818_802_733_994_939_422_391_117_889_488_426_048_064_214_464_807_202_678_057_814_506_857_598_216_519_713_500_367_054_751_798_085_721_175_479_253_718_721_128_486_079_664_202_366_173_291_604_729_149_002_231_216_365_881_810_559_170_806_779_025_870_730_014_084_702_667_165_448_007_235_200_987_855_525_273_872_722_215_577_190_207_735_445_331_571_211_390_355_838_289_869_579_550_719_903_997_372_837_189_990_257_205_625_911_327_200_960_755_961_994_062_392_857_814_623_927_220_777_221_801_084_795_932_729_073_692_044_686_769_833_905_352_721_957_914_989_988_356_488_139_696_938_688_580_054_858_491_441_425_957_305_503_349_608_380_717_737_047_724_774_228_463_593_205_537_518_100_423_351_999_443_851_498_455_439_855_233_622_545_947_953_242_965_160_199,
                 65537}}
           },
           "fcbd7f481a825d113e0d03dd94e60b69ff1665a2" => %JOSE.JWK{
             fields: %{},
             keys: :undefined,
             kty:
               {:jose_jwk_kty_rsa,
                {:RSAPublicKey,
                 20_607_799_286_815_146_346_272_668_957_764_259_713_609_522_835_284_084_414_263_366_121_293_312_450_630_380_229_613_310_193_301_498_051_252_378_522_246_226_676_648_265_089_290_399_678_929_787_883_796_114_269_101_050_988_064_877_055_583_474_452_395_487_137_975_960_148_794_655_466_190_540_959_601_168_013_190_075_672_302_186_992_186_644_667_213_300_395_315_982_297_191_556_573_839_399_323_171_929_230_034_233_552_329_926_110_604_103_229_026_703_629_208_478_118_611_161_180_909_316_136_553_658_156_277_681_295_466_757_962_316_591_325_061_933_874_129_933_603_707_401_592_250_873_384_044_665_326_478_104_397_695_347_476_506_070_514_388_372_695_740_797_007_652_083_761_332_388_386_922_039_548_603_285_961_334_198_439_167_810_663_616_826_529_750_962_414_137_538_761_830_927_148_610_959_967_340_059_365_762_695_060_857_354_124_641,
                 65537}}
           }
         }}
      ]

      key_id = "fcbd7f481a825d113e0d03dd94e60b69ff1665a2"

      assert sample_ets_lookup |> GoogleCerts.jwk_from_ets(key_id) == %JOSE.JWK{
               fields: %{},
               keys: :undefined,
               kty:
                 {:jose_jwk_kty_rsa,
                  {:RSAPublicKey,
                   20_607_799_286_815_146_346_272_668_957_764_259_713_609_522_835_284_084_414_263_366_121_293_312_450_630_380_229_613_310_193_301_498_051_252_378_522_246_226_676_648_265_089_290_399_678_929_787_883_796_114_269_101_050_988_064_877_055_583_474_452_395_487_137_975_960_148_794_655_466_190_540_959_601_168_013_190_075_672_302_186_992_186_644_667_213_300_395_315_982_297_191_556_573_839_399_323_171_929_230_034_233_552_329_926_110_604_103_229_026_703_629_208_478_118_611_161_180_909_316_136_553_658_156_277_681_295_466_757_962_316_591_325_061_933_874_129_933_603_707_401_592_250_873_384_044_665_326_478_104_397_695_347_476_506_070_514_388_372_695_740_797_007_652_083_761_332_388_386_922_039_548_603_285_961_334_198_439_167_810_663_616_826_529_750_962_414_137_538_761_830_927_148_610_959_967_340_059_365_762_695_060_857_354_124_641,
                   65537}}
             }
    end

    test "it sends another get request if failed to retrieve keys from google certs url" do
    end

    test "the public keys are refreshed upon expiring" do
    end
  end

  describe "genserver" do
    test "jwks/1 returns the correct map" do
      assert GoogleCerts.jwks(@example_res) == %{
               "fcbd7f481a825d113e0d03dd94e60b69ff1665a2" => %JOSE.JWK{
                 fields: %{},
                 keys: :undefined,
                 kty: {
                   :jose_jwk_kty_rsa,
                   {
                     :RSAPublicKey,
                     20_607_799_286_815_146_346_272_668_957_764_259_713_609_522_835_284_084_414_263_366_121_293_312_450_630_380_229_613_310_193_301_498_051_252_378_522_246_226_676_648_265_089_290_399_678_929_787_883_796_114_269_101_050_988_064_877_055_583_474_452_395_487_137_975_960_148_794_655_466_190_540_959_601_168_013_190_075_672_302_186_992_186_644_667_213_300_395_315_982_297_191_556_573_839_399_323_171_929_230_034_233_552_329_926_110_604_103_229_026_703_629_208_478_118_611_161_180_909_316_136_553_658_156_277_681_295_466_757_962_316_591_325_061_933_874_129_933_603_707_401_592_250_873_384_044_665_326_478_104_397_695_347_476_506_070_514_388_372_695_740_797_007_652_083_761_332_388_386_922_039_548_603_285_961_334_198_439_167_810_663_616_826_529_750_962_414_137_538_761_830_927_148_610_959_967_340_059_365_762_695_060_857_354_124_641,
                     65537
                   }
                 }
               },
               "861649e450315383f6b9d510b7cd4e9226c3cd88" => %JOSE.JWK{
                 fields: %{},
                 keys: :undefined,
                 kty:
                   {:jose_jwk_kty_rsa,
                    {:RSAPublicKey,
                     21_349_497_452_354_290_018_764_659_372_085_680_653_532_128_893_835_754_604_122_939_921_096_531_889_488_030_266_080_107_916_371_316_332_146_689_199_792_398_353_703_700_437_964_941_634_955_273_669_785_140_622_365_501_713_480_886_877_924_800_469_884_361_473_271_875_742_491_950_193_442_970_247_904_407_321_814_587_273_015_264_359_135_300_146_087_762_535_444_156_977_955_531_264_064_616_391_360_544_681_747_820_270_671_804_006_389_769_260_177_274_109_106_409_067_447_116_882_134_494_360_598_093_055_507_227_894_171_112_372_792_874_145_068_784_265_273_608_611_468_380_940_836_016_878_168_051_731_780_152_400_377_192_707_801_740_360_203_469_713_071_548_901_578_946_834_009_515_157_262_602_053_005_669_270_118_274_830_591_509_116_106_657_706_698_563_652_116_096_000_469_550_975_936_708_164_413_333_295_220_407_689_597_181_018_783,
                     65537}}
               }
             }
    end
  end

  describe "key cache" do
    @key_cache :foo

    test "maybe_create_key_cache/1 creates a cache when one doesn't exist" do
      assert GoogleCerts.maybe_create_key_cache(@key_cache) == :foo
    end

    test "maybe_create_key_cache/1 does not do anything when a key cache already exists" do
      GoogleCerts.maybe_create_key_cache(@key_cache)
      assert GoogleCerts.maybe_create_key_cache(@key_cache) == []
    end
  end

  test "seconds_to_expire/1 returns the correct number of seconds" do
    assert GoogleCerts.seconds_to_expire(@example_res) == 24385
  end

  test "age/1 returns the correct age as an Integer" do
    assert GoogleCerts.age(@example_res) == 45
  end

  test "max_age/1 returns the correct max-age as an Integer" do
    assert GoogleCerts.max_age(@example_res) == 24430
  end

  test "get_header/2 returns the correct header" do
    assert GoogleCerts.get_header(@example_res, "Age") == "45"
  end

  test "get_header/2 returns an error if header cannot be found" do
    assert_raise(
      GoogleCerts.Error,
      fn ->
        GoogleCerts.get_header(@example_res, "Does-Not-Exist")
      end
    )
  end

  test "extract_max_age/1 returns an error if max-age cannot be found" do
    assert_raise(
      GoogleCerts.Error,
      fn ->
        GoogleCerts.extract_max_age([])
      end
    )
  end
end

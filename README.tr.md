<div align="center">

# LunaMaxxing

**Gerçek kullanım, test ve tekrarlarla geliştirilen kalite odaklı Codex skill'leri.**

[![Codex Skill](https://img.shields.io/badge/Codex-Skill-111827?style=for-the-badge)](https://developers.openai.com/codex/)
[![Durum](https://img.shields.io/badge/durum-deneysel-f59e0b?style=for-the-badge)](#proje-durumu)
[![Lisans: MIT](https://img.shields.io/badge/lisans-MIT-22c55e?style=for-the-badge)](LICENSE)

[English](README.md) · [Türkçe](README.tr.md) · [Kurulum](#kurulum) · [Nasıl çalışır?](#lunamaxxing-nasıl-çalışır)

</div>

---

**LunaMaxxing**, Luna Max'in görevleri daha güçlü bir süreçle çözmesine yardımcı olmak için tasarlanmış uyarlanabilir bir Codex analiz, planlama, uygulama ve doğrulama iş akışıdır.

> [!IMPORTANT]
> LunaMaxxing, Luna'nın yapısal olarak daha güçlü bir modelle eşit hâle geldiğini iddia etmez. Modelin çevresindeki süreci güçlendirerek zor görevlerin yüzeysel bir ilk cevapla bitme olasılığını azaltır.

## Mevcut skill'ler

| Skill | Amaç | Durum |
| --- | --- | --- |
| [`lunamaxxing`](skills/lunamaxxing) | Uyarlanabilir derinlikle kalite odaklı analiz, planlama, uygulama ve doğrulama | Deneysel |

## Neden LunaMaxxing?

Ucuz akıl yürütme, ancak ek çalışma düzenli olduğunda değerlidir. LunaMaxxing uzun çalışmaları amaçlı hâle getiren sınırlar ekler:

- **Açık çağrı:** yalnızca kullanıcı istediğinde çalışır.
- **Önce mevcut oturum:** konuşma bağlamını varsayılan olarak korur.
- **Kontrollü worker:** sabitlenmiş Luna Max CLI worker yalnızca açıkça istenirse başlatılır.
- **Config'i koruyan worker:** ayrı worker, izolasyon açıkça seçilmedikçe kullanıcının Codex ayarlarını devralır.
- **Uyarlanabilir derinlik:** basit `0–5` puanı Light, Standard veya Deep seviyesini seçer.
- **Sınırlı tekrar:** sonsuz cilalamayı önlemek için düzeltme turları sınırlandırılır.
- **Yetki sınırları:** analiz görevi sessizce uygulamaya veya harici işleme dönüşmez.
- **Kanıta bağlı güven:** uzun metin güveni yükseltmez; güçlü kanıt yükseltebilir.
- **Göreve özel modüller:** ürün, araştırma, hata ayıklama, yaratıcı çalışma ve görsel QA yalnızca gerektiğinde yüklenir.

## Kurulum

### Seçenek A — Codex'ten yüklemesini isteyin

Yerleşik skill yükleyiciyi kullanın:

```text
Use $skill-installer to install lunamaxxing from
https://github.com/HakanBabus/LunaMaxxing/tree/main/skills/lunamaxxing
```

Yüklenen skill bir sonraki Codex turunda kullanılabilir olur.

### Seçenek B — Yerleşik yükleyici script ile kurun

```powershell
python "$env:USERPROFILE\.codex\skills\.system\skill-installer\scripts\install-skill-from-github.py" `
  --repo HakanBabus/LunaMaxxing `
  --path skills/lunamaxxing
```

Aynı isimde bir skill zaten varsa yükleyici güvenli biçimde durur.

<details>
<summary><strong>Manuel kurulum</strong></summary>

Depoyu klonlayın ve skill klasörünü Codex skill dizininize kopyalayın:

```powershell
git clone https://github.com/HakanBabus/LunaMaxxing.git
Copy-Item -Recurse `
  .\LunaMaxxing\skills\lunamaxxing `
  "$env:USERPROFILE\.codex\skills\lunamaxxing"
```

Kurulumdan sonra yeni bir Codex turu başlatın.

</details>

## Kullanım

Skill'i açıkça çağırın:

```text
Use $lunamaxxing to analyze this product problem, choose the strongest direction,
implement it step by step, and verify the result.
```

Farklı bir worker açıkça istenmediği sürece skill mevcut oturumda kalır:

```text
Use $lunamaxxing in a separate pinned Luna Max CLI worker for this task.
```

Ayrı worker'lar bilinçli olarak **tek seferliktir ve resume edilemez**. Her açık istek yalnızca bir ephemeral worker'a yetki verir. Normal Codex config'i, tanımlı MCP sunucuları ve tercihler varsayılan olarak devralınır; config izolasyonu gerekiyorsa ayrıca açıkça istenmelidir.

`-OutputLastMessage` mutlak bir yolu veya `-Workdir` göreli bir yolu kabul eder. Launcher, eksik çıktı klasörünü yalnızca gerçek worker çalışırken oluşturur; `-DryRun` hiçbir şey yazmaz.

<details>
<summary><strong>Daha fazla örnek prompt</strong></summary>

```text
Use $lunamaxxing to diagnose this regression before changing any code.
```

```text
Use $lunamaxxing to compare three product directions, select one, implement it,
and validate the user-visible result.
```

```text
Use $lunamaxxing to research this decision, separate facts from inference,
and produce an implementation-ready plan.
```

</details>

## LunaMaxxing nasıl çalışır?

1. **Yetkiyi korur** — isteğin yalnızca analiz, yerel değişiklik veya harici işlem yetkilerinden hangisini verdiğini belirler.
2. **Rotayı seçer** — varsayılan olarak mevcut oturumda devam eder; yalnızca açıkça istenirse worker başlatır.
3. **Görevi puanlar** — beş basit belirsizlik ve risk sinyaliyle derinliği seçer.
4. **Başarıyı tanımlar** — sonuç, kabul kriterleri, kısıtlar, korunacak davranışlar ve riskleri yazar.
5. **Kanıt toplar** — gerçek sistemi inceler ve alternatif açıklamaları sınar.
6. **Seçenek üretir ve karar verir** — görev gerektiriyorsa birbirinden gerçekten farklı yönler oluşturur.
7. **Adım adım uygular** — odaklı değişiklikler yapar ve her sonucu inceler.
8. **Bağımsız doğrular** — amaç, davranış, çıktı, regresyon ve en zararlı olası hatayı test eder.
9. **Güveni raporlar** — Low, Medium veya High seviyesini gerçek doğrulama kanıtlarına bağlar.

### Uyarlanabilir derinlik

| Puan | Seviye | Varsayılan düzeltme sınırı | Tipik kullanım |
| ---: | --- | ---: | --- |
| `0–1` | Light | 1 | Yerel, belirgin ve düşük riskli işler |
| `2–3` | Standard | 2 | Belirsizlik veya alternatif içeren ciddi işler |
| `4–5` | Deep | 3 | Muğlak, birçok alanı etkileyen, riskli veya çok durumlu işler |

Bu sınırlar hedef değil, üst limittir. Kanıt kabul kriterlerini destekliyorsa süreç erkenden durur.

## Depo yapısı

```text
LunaMaxxing/
├─ .github/workflows/test.yml
├─ skills/
│  └─ lunamaxxing/
│     ├─ SKILL.md
│     ├─ agents/openai.yaml
│     ├─ references/
│     └─ scripts/
├─ tests/test-lunamaxxing.ps1
├─ README.md
├─ README.tr.md
├─ CONTRIBUTING.md
└─ LICENSE
```

## Güvenlik ve sınırlar

- Skill; yıkıcı işlemler, satın alma, kimlik bilgisi kullanımı, production değişikliği veya kapsam genişletme yetkisi vermez.
- Model kimliği yalnızca çalışma zamanı verisi doğruladığında veya launcher sabitlediğinde raporlanır.
- Sırf daha fazla düşünme süresi kazanmak için ayrı worker oluşturulmaz.
- Ayrı worker'lar ephemeral ve tek seferliktir; kapandıktan sonra resume edilemez.
- Kullanıcının Codex config'i varsayılan olarak devralınır; izole config opt-in'dir.
- Bazı CLI parametreleri ve model kimlikleri kullanıcının Codex sürümüne ve hesap erişimine bağlı olabilir.
- Proje deneyseldir; yüksek etkili işlerde kullanmadan önce iş akışını inceleyin.

## Proje durumu

Mevcut sürüm pratik test ve herkese açık geliştirme için hazırdır. Tekrarlanabilir örnek görevler, Luna Max ile LunaMaxxing karşılaştırmaları, değerlendirme tabloları ve görsel sonuç grafikleri daha sonra eklenecektir.

## Katkıda bulunma

Issue'lar ve odaklı pull request'ler kabul edilir. Ayrıntılar için [CONTRIBUTING.md](CONTRIBUTING.md) dosyasına bakın.

## Lisans

[MIT Lisansı](LICENSE) altında yayımlanmıştır.

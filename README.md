# Meme Launchpad 🔥🚀
Sebuah platform launchpad token komunitas sepenuhnya **on-chain**, terintegrasi penuh dengan **Uniswap V4**, mirip seperti [flaunch.gg](https://flaunch.gg) dan [pump.fun](https://pump.fun).

## 🌐 Live Network
- Jaringan: **Base Sepolia**
- Token Launch: On-chain (Deploy otomatis setelah target ETH tercapai)
- LP Token: **Burned Permanently** (tidak bisa ditarik oleh siapa pun)
- Fee: Creator & Community berbagi hasil trading fee via Hook Uniswap V4

---

## 📁 Struktur Proyek
meme-launchpad/
├── contracts/
│ ├── MemeCampaignManager.sol # Core logic semua kampanye
│ ├── UnlockerToken.sol # ERC20 token custom
│ ├── Hook.sol # Hook Uniswap V4 untuk fee distribusi
│ ├── interfaces/
│ │ ├── IHook.sol
│ │ ├── IUniswapV4Factory.sol
│ │ ├── IUniswapPool.sol
│ │ ├── IWETH.sol
│ │ └── IUnlockerToken.sol
│ └── utils/
│ └── TransferHelper.sol
│
├── deploy/
│ ├── config.js # Konfigurasi WETH, factory, dev wallet, dll.
│ ├── deployManager.js # Deploy MemeCampaignManager
│ ├── deployHook.js # Deploy Hook Uniswap
│ └── deployFullCampaign.js # Simulasi lengkap dari awal sampai peluncuran
│
├── test/
│ ├── manager.test.js
│ ├── hook.test.js
│ ├── unlockerToken.test.js
│ └── integration.test.js # Full flow: create → fund → deploy → verify
│
├── scripts/
│ └── simulateFunding.js # Simulasi partisipasi kontributor
│
├── .env # PRIVATE_KEY, RPC_URL (Base Sepolia)
├── hardhat.config.js
├── package.json
└── README.md


## ⚙️ Fitur Utama

### Mode Peluncuran
- **Simple Mode**: 
  - Gratis.
  - Fee tetap: 85% untuk creator, 15% untuk komunitas (buyback token).
  - Distribusi token proporsional berdasarkan kontribusi.

- **Advanced Mode**:
  - Creator pilih fee (misal 70/30).
  - Dua sub-mode:
    - **Normal**: Sama seperti Simple, tapi fee bisa dikustom.
    - **Degen**: 
      - Kontribusi tetap 0.0005 ETH.
      - Alokasi token **acak/random**.
      - Bisa dilakukan berulang.

### Otomatisasi
- Token akan dideploy **hanya setelah target funding tercapai**.
- 97.5% dari ETH digunakan untuk membuat pool (LP) di Uniswap V4.
- 2.5% dikirim ke developer wallet.

### Hook Uniswap V4
- **afterSwap()** memanggil manager untuk mendistribusi fee:
  - Creator dapat fee ke wallet.
  - Community fee disimpan ke address buyback (bisa dikelola terpisah).

---

## 🧪 Testing
Jalankan test:
```bash
npx hardhat test

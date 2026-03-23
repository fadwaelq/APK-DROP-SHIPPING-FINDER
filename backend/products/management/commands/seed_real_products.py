import requests
import time
import uuid
from decimal import Decimal
from django.core.management.base import BaseCommand
from products.models import Product

class Command(BaseCommand):
    help = 'Appelle l\'API locale pour scraper de vrais produits avec la sécurité anti-doublon et anti-demo'

    def handle(self, *args, **kwargs):
        API_URL = "http://127.0.0.1:8000/api/bulk-search/"
  #      📱 LISTE : TÉLÉPHONES, MARQUES & ACCESSOIRES MOBILES
        mots_cles = [
            # Smartphones (Versions Globales & Téléphones incassables)
            "global version smartphone 5g", "rugged waterproof phone", 
            "gaming smartphone 120hz", "folding screen android phone",
            "xiaomi poco x6 pro", "redmi note 13 pro global", "oneplus 12",
            
            # Accessoires Apple / iPhone (Très forte demande, acheteurs impulsifs)
            "iphone 15 pro max magnetic case", "magsafe wireless charger",
            "apple watch silicone band", "airpods pro protective case",
            "privacy tempered glass iphone", "iphone camera lens protector",
            
            # Accessoires Samsung & Android (Volume massif)
            "samsung galaxy s24 ultra case", "samsung 45w super fast charger",
            "s23 fe screen protector", "google pixel 8 pro clear case",
            "type c to 3.5mm headphone adapter", "samsung watch 6 strap",
            
            # Gadgets de Charge & Batteries (Gros profits en dropshipping)
            "100w gan fast charger", "10000mah magnetic power bank",
            "3 in 1 wireless charging station", "car phone holder wireless charger",
            "usb c to usb c braided cable 100w", "solar power bank 20000mah",
            
            # Création de contenu, Vidéo & Auto/Moto
            "smartphone gimbal stabilizer", "ring light with phone tripod",
            "mini wireless microphone for phone", "motorcycle phone mount waterproof",
            "magnetic phone ring holder stand", "lazy neck phone holder"
        ]

        self.stdout.write(self.style.SUCCESS(f"Lancement du scraping pour {len(mots_cles)} ..."))

        produits_ajoutes = 0
        lot_size = 2 

        for i in range(0, len(mots_cles), lot_size):
            lot = mots_cles[i:i + lot_size]
            self.stdout.write(f"\n🔍 Recherche en cours pour : {lot}...")
            
            payload = {
                "items": lot,
                "platform": "aliexpress"
            }
            headers = {"Content-Type": "application/json"}
            
            try:
                response = requests.post(API_URL, json=payload, headers=headers)
                
                if response.status_code == 200:
                    resultats = response.json()
                    details = resultats.get("data", {}).get("details", [])
                    
                    for item in details:
                        if item.get("status") == "success":
                            data = item.get("data")
                            titre = data.get("title", "")
                            
                            #  SÉCURITÉ ANTI-BLOCAGE : On ignore les produits factices (DEMO)
                            if "DEMO" in titre.upper():
                                self.stdout.write(self.style.WARNING(f"⚠️ AliExpress a bloqué. Faux produit ignoré pour : {item.get('input')}"))
                                continue # Saute ce produit et passe au suivant !
                            
                            # 🛡️ CORRECTIF URL : Si AliExpress renvoie une URL générique
                            source_url = data.get("source_url", "")
                            if source_url in ["https://www.aliexpress.com", "https://www.aliexpress.com/", ""]:
                                identifiant_unique = uuid.uuid4().hex[:8]
                                source_url = f"https://www.aliexpress.com/item/fallback_{identifiant_unique}.html"
                            
                            if not Product.objects.filter(aliexpress_url=source_url).exists():
                                Product.objects.create(
                                    title=titre[:255],
                                    price=Decimal(str(data.get("cost_mad", 0))),
                                    aliexpress_url=source_url,
                                    image_url=data.get("image_url"),
                                    category=data.get("category", "General"),
                                    suggested_sale_price=Decimal(str(data.get("suggested_sale_price", 0))),
                                    potential_profit=Decimal(str(data.get("potential_profit", 0))),
                                    trend_score=data.get("trend_score", 0),
                                    is_winner=data.get("is_winner", False),
                                    ai_analysis_summary=data.get("ai_analysis_summary", "")
                                )
                                produits_ajoutes += 1
                                self.stdout.write(self.style.SUCCESS(f"✅ Ajouté : {titre[:40]}..."))
                            else:
                                self.stdout.write(self.style.WARNING(f"⚠️ Déjà en base : {source_url}"))
                        else:
                            self.stdout.write(self.style.ERROR(f"❌ Échec pour : {item.get('input')}"))
                else:
                    self.stdout.write(self.style.ERROR(f"Erreur API : {response.status_code}"))
                    
            except requests.exceptions.ConnectionError:
                self.stdout.write(self.style.ERROR("❌ Erreur : Le serveur Django n'est pas allumé."))
                return

            # 🛡️ SECURITE ANTI-BAN : On fait une pause de 5 secondes 
            self.stdout.write("⏳ Pause de sécurité de 5 secondes...")
            time.sleep(5)

        self.stdout.write(self.style.SUCCESS(f"\n🎉 Terminé ! {produits_ajoutes} VRAIS produits ont été ajoutés à la base."))
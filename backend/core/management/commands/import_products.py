"""
Django management command to import products from external sources
Usage: python manage.py import_products <query> [--pages=3] [--no-tor]
"""
from django.core.management.base import BaseCommand
from integrations.tasks import sync_aliexpress_products, sync_trending_products


class Command(BaseCommand):
    help = 'Import products from external sources (AliExpress, Amazon, etc.)'
    
    def add_arguments(self, parser):
        parser.add_argument(
            'query',
            nargs='?',
            type=str,
            help='Search query for products',
        )
        parser.add_argument(
            '--pages',
            type=int,
            default=3,
            help='Number of pages to scrape (default: 3)',
        )
        parser.add_argument(
            '--no-tor',
            action='store_true',
            help='Disable Tor proxy',
        )
        parser.add_argument(
            '--trending',
            action='store_true',
            help='Import trending products from popular categories',
        )
    
    def handle(self, *args, **options):
        query = options.get('query')
        pages = options.get('pages', 3)
        use_tor = not options.get('no_tor', False)
        trending = options.get('trending', False)
        
        self.stdout.write(self.style.SUCCESS('=' * 60))
        self.stdout.write(self.style.SUCCESS('🚀 DROPSHIPPING FINDER - Product Import'))
        self.stdout.write(self.style.SUCCESS('=' * 60))
        
        if trending:
            self.stdout.write('\n📈 Importing trending products from popular categories...')
            self.stdout.write(f'Using Tor: {"Yes" if use_tor else "No"}\n')
            
            stats = sync_trending_products(use_tor=use_tor)
            
            self.stdout.write('\n' + '=' * 60)
            self.stdout.write(self.style.SUCCESS('✅ Import completed!'))
            self.stdout.write('=' * 60)
            self.stdout.write(f"Categories processed: {stats['categories_processed']}")
            self.stdout.write(self.style.SUCCESS(f"✅ Products created: {stats['total_created']}"))
            self.stdout.write(self.style.WARNING(f"🔄 Products updated: {stats['total_updated']}"))
            self.stdout.write(self.style.ERROR(f"❌ Errors: {stats['total_errors']}"))
            self.stdout.write('=' * 60)
            
        elif query:
            self.stdout.write(f'\n🔍 Searching for: "{query}"')
            self.stdout.write(f'Pages to scrape: {pages}')
            self.stdout.write(f'Using Tor: {"Yes" if use_tor else "No"}\n')
            
            self.stdout.write('⏳ Starting import... This may take a few minutes.\n')
            
            stats = sync_aliexpress_products(query, max_pages=pages, use_tor=use_tor)
            
            self.stdout.write('\n' + '=' * 60)
            self.stdout.write(self.style.SUCCESS('✅ Import completed!'))
            self.stdout.write('=' * 60)
            self.stdout.write(f"Total products found: {stats['total_found']}")
            self.stdout.write(self.style.SUCCESS(f"✅ Products created: {stats['created']}"))
            self.stdout.write(self.style.WARNING(f"🔄 Products updated: {stats['updated']}"))
            self.stdout.write(self.style.ERROR(f"❌ Errors: {stats['errors']}"))
            self.stdout.write('=' * 60)
            
        else:
            self.stdout.write(self.style.ERROR('\n❌ Error: Please provide a search query or use --trending'))
            self.stdout.write('\nExamples:')
            self.stdout.write('  python manage.py import_products "wireless earbuds"')
            self.stdout.write('  python manage.py import_products "smart watch" --pages=5')
            self.stdout.write('  python manage.py import_products --trending')
            self.stdout.write('  python manage.py import_products "phone case" --no-tor\n')

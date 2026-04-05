from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from services.models import Service, Helper

User = get_user_model()

SERVICES = [
    ('Cleaning', 'Professional home and office cleaning'),
    ('Electrician', 'Electrical installation and repair'),
    ('Plumber', 'Plumbing and pipe repair'),
    ('Cook', 'Home cooking and meal preparation'),
    ('Babysitter', 'Childcare and babysitting'),
]

HELPERS = [
    {'username': 'ram_cleaner', 'name': 'Ram Bahadur', 'phone': '9801234567', 'service': 'Cleaning',    'price': 500,  'location': 'Kathmandu', 'rating': 4.8},
    {'username': 'sita_elec',   'name': 'Sita Sharma', 'phone': '9812345678', 'service': 'Electrician', 'price': 800,  'location': 'Lalitpur',   'rating': 4.5},
    {'username': 'hari_plumb',  'name': 'Hari Prasad', 'phone': '9823456789', 'service': 'Plumber',     'price': 700,  'location': 'Bhaktapur',  'rating': 4.6},
    {'username': 'mina_cook',   'name': 'Mina Gurung', 'phone': '9834567890', 'service': 'Cook',        'price': 600,  'location': 'Kathmandu',  'rating': 4.9},
    {'username': 'rita_baby',   'name': 'Rita Tamang', 'phone': '9845678901', 'service': 'Babysitter',  'price': 450,  'location': 'Lalitpur',   'rating': 4.7},
]

USERS = [
    {'username': 'demo_user1', 'email': 'user1@demo.com', 'phone': '9851234567'},
    {'username': 'demo_user2', 'email': 'user2@demo.com', 'phone': '9852345678'},
    {'username': 'demo_user3', 'email': 'user3@demo.com', 'phone': '9853456789'},
    {'username': 'demo_user4', 'email': 'user4@demo.com', 'phone': '9854567890'},
    {'username': 'demo_user5', 'email': 'user5@demo.com', 'phone': '9855678901'},
]

class Command(BaseCommand):
    help = 'Seed demo users and helpers'

    def handle(self, *args, **options):
        # Create services
        service_map = {}
        for name, desc in SERVICES:
            svc, created = Service.objects.get_or_create(name=name, defaults={'description': desc})
            service_map[name] = svc
            if created:
                self.stdout.write(self.style.SUCCESS(f'  ✅ Service: {name}'))

        # Create helper users
        self.stdout.write('\n--- Creating Helpers ---')
        for h in HELPERS:
            user, created = User.objects.get_or_create(
                username=h['username'],
                defaults={
                    'email': f"{h['username']}@demo.com",
                    'phone': h['phone'],
                    'role': 'helper',
                    'first_name': h['name'].split()[0],
                    'last_name': h['name'].split()[1] if len(h['name'].split()) > 1 else '',
                }
            )
            if created:
                user.set_password('demo1234')
                user.save()
            helper, h_created = Helper.objects.get_or_create(
                user=user,
                defaults={
                    'service': service_map[h['service']],
                    'price': h['price'],
                    'location': h['location'],
                    'rating': h['rating'],
                }
            )
            status = '✅ Created' if created else '⚠️  Already exists'
            self.stdout.write(f"  {status}: {h['name']} ({h['service']}) @ {h['location']} — NPR {h['price']}/visit")

        # Create regular users
        self.stdout.write('\n--- Creating Users ---')
        for u in USERS:
            user, created = User.objects.get_or_create(
                username=u['username'],
                defaults={'email': u['email'], 'phone': u['phone'], 'role': 'user'}
            )
            if created:
                user.set_password('demo1234')
                user.save()
            status = '✅ Created' if created else '⚠️  Already exists'
            self.stdout.write(f"  {status}: {u['username']} ({u['email']})")

        self.stdout.write(self.style.SUCCESS('\n🎉 Demo seed complete! Password for all accounts: demo1234'))

# Generated by Django 4.2.17 on 2024-12-18 10:27

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('bookchat', '0002_alter_book_poster_bookmemo'),
    ]

    operations = [
        migrations.AddField(
            model_name='book',
            name='description',
            field=models.TextField(blank=True, null=True),
        ),
    ]
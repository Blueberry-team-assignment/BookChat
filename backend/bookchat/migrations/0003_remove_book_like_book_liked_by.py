# Generated by Django 4.2.17 on 2025-01-10 04:04

from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('bookchat', '0002_comment_chatroom_chatmessage'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='book',
            name='like',
        ),
        migrations.AddField(
            model_name='book',
            name='liked_by',
            field=models.ManyToManyField(blank=True, related_name='liked_books', to=settings.AUTH_USER_MODEL),
        ),
    ]

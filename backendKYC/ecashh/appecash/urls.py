from django.urls import path
from .views import   fetch_person_info,getPersonnes, createPersonne, match_face_opencv, updatePersonne, deletePersonne
from appecash import views

urlpatterns = [
    path('personne/<int:pk>/', getPersonnes, name='get_personne'),
    path('personnes/', getPersonnes, name='get_personnes'),
    path('personne/create/', createPersonne, name='create_personne'),
    path('personne/update/<int:pk>/', updatePersonne, name='update_personne'),
    path('personne/delete/<int:pk>/', deletePersonne, name='delete_personne'),
    path('fetch-person-info/', fetch_person_info, name='fetch_person_info'),
    path('match-face/', match_face_opencv, name='match_face'),
    #path('test-camera/', test_camera, name='test_camera'),
    #path('capture-image/', capture_image, name='capture-image'),
]

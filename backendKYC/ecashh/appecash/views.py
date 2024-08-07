import base64
import json
import logging
import os
import shutil
import subprocess
import threading
import cv2
from django.http import HttpResponse, JsonResponse
from rest_framework import generics, serializers
from django.views.decorators.csrf import csrf_exempt
from ecashh import settings
from .models import Personne
from .serializers import PersonneSerializer
from rest_framework.decorators import api_view
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework.status import HTTP_200_OK, HTTP_400_BAD_REQUEST, HTTP_404_NOT_FOUND, HTTP_204_NO_CONTENT
import dlib
import numpy as np


@api_view(['GET'])
def get_personne(request, pk):
    try:
        personne = Personne.objects.get(pk=pk)
        serializer = PersonneSerializer(personne, context={'request': request})
        return Response(serializer.data)
    except Personne.DoesNotExist:
        return Response({'message': 'Personne not found'}, status=404)

@api_view(['GET'])
def getPersonnes(request):
    personnes = Personne.objects.all()
    serializer = PersonneSerializer(personnes, many=True)
    return Response(data={"personnes": serializer.data}, status=HTTP_200_OK)

@api_view(['POST'])
def createPersonne(request):
    serializer = PersonneSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(data={"msg": "Personne has been created successfully!", "personne": serializer.data}, status=HTTP_200_OK)
    else:
        return Response(data={"msg": "Failed to create Personne!", "errors": serializer.errors}, status=HTTP_400_BAD_REQUEST)

@api_view(['PUT'])
def updatePersonne(request, pk):
    try:
        personne = Personne.objects.get(pk=pk)
    except Personne.DoesNotExist:
        return Response(data={"msg": "Personne not found!"}, status=HTTP_404_NOT_FOUND)
    
    serializer = PersonneSerializer(personne, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response(data={"msg": "Personne has been updated successfully!", "personne": serializer.data}, status=HTTP_200_OK)
    else:
        return Response(data={"msg": "Failed to update Personne!", "errors": serializer.errors}, status=HTTP_400_BAD_REQUEST)

@api_view(['DELETE'])
def deletePersonne(request, pk):
    try:
        personne = Personne.objects.get(pk=pk)
        personne.delete()
        return Response(data={"msg": "Personne has been deleted successfully!"}, status=HTTP_204_NO_CONTENT)
    except Personne.DoesNotExist:
        return Response(data={"msg": "Personne not found!"}, status=HTTP_404_NOT_FOUND)
    
    

logging.basicConfig(level=logging.DEBUG)

# Fonction pour récupérer les informations de l'utilisateur et copier l'image
def fetch_person_info(request):
    nni = request.GET.get('nni')
    numero_tel = request.GET.get('numero_tel')

    if not nni or not numero_tel:
        return JsonResponse({'error': 'NNI and phone number are required.'}, status=400)

    try:
        person = Personne.objects.get(NNI=nni, numero_tel=numero_tel)
        
        # Extraire le chemin de l'image et sauvegarder l'image dans un dossier spécifique
        if person.img:
            # Créer le dossier s'il n'existe pas
            image_folder = os.path.join(settings.MEDIA_ROOT, 'user_images')
            if not os.path.exists(image_folder):
                os.makedirs(image_folder)
            
            # Chemin de l'image d'origine
            original_image_path = person.img.path
            
            # Nouveau chemin de l'image
            new_image_path = os.path.join(image_folder, f"{nni}.png")
            
            # Copier l'image vers le nouveau chemin
            shutil.copyfile(original_image_path, new_image_path)
        
        # Préparer les données de l'objet person pour la réponse
        person_data = {
            'id': person.id,
            'NNI': person.NNI,
            'numero_tel': person.numero_tel,
            'date_naissance': person.date_naissance.strftime('%Y-%m-%d'),  # Formatage de la date pour la compatibilité JSON
            'img_url': request.build_absolute_uri(person.img.url) if person.img else '',  # Utiliser img_url au lieu de img
            'lieu_naissance_ar': person.lieu_naissance_ar,
            'lieu_naissance_fr': person.lieu_naissance_fr,
            'nationalite_iso': person.nationalite_iso,
            'nom_famille_ar': person.nom_famille_ar,
            'nom_famille_fr': person.nom_famille_fr,
            'prenom_ar': person.prenom_ar,
            'prenom_fr': person.prenom_fr,
            'prenom_pere_ar': person.prenom_pere_ar,
            'prenom_pere_fr': person.prenom_pere_fr,
            'sexe_fr': person.sexe_fr,
        }
        return JsonResponse({'person': person_data}, status=200)
    except Personne.DoesNotExist:
        return JsonResponse({'error': 'Person not found.'}, status=404)


# Fonction pour correspondre le visage capturé avec l'image de référence
@csrf_exempt
def match_face_opencv(request):
    nni = request.GET.get('nni')
    if not nni:
        return JsonResponse({'error': 'Le paramètre NNI est requis'}, status=400)

    ref_image_path = os.path.join(settings.MEDIA_ROOT, 'user_images', f'{nni}.png')
    if not os.path.exists(ref_image_path):
        return JsonResponse({'error': "L'image de référence n'est pas trouvée"}, status=404)

    ref_image = cv2.imread(ref_image_path)
    if ref_image is None:
        return JsonResponse({'error': "Échec du chargement de l'image de référence"}, status=500)

    detector = dlib.get_frontal_face_detector()
    predictor = dlib.shape_predictor(settings.SHAPE_PREDICTOR_PATH)
    face_rec_model = dlib.face_recognition_model_v1(settings.FACE_RECOGNITION_MODEL_PATH)

    ref_faces = detector(ref_image, 1)
    if len(ref_faces) == 0:
        return JsonResponse({'error': "Aucun visage détecté dans l'image de référence"}, status=400)

    ref_descriptors = []
    for ref_face in ref_faces:
        ref_shape = predictor(ref_image, ref_face)
        ref_descriptor = face_rec_model.compute_face_descriptor(ref_image, ref_shape)
        ref_descriptors.append(np.array(ref_descriptor))

    if request.method == 'POST':
        file = request.FILES['image']
        live_image = cv2.imdecode(np.frombuffer(file.read(), np.uint8), cv2.IMREAD_COLOR)

        if live_image is None:
            return JsonResponse({'error': 'Failed to read live image'}, status=400)

        live_faces = detector(live_image, 1)
        if len(live_faces) == 0:
            cv2.imwrite(os.path.join(settings.MEDIA_ROOT, 'debug_live_image.png'), live_image)
            return JsonResponse({'error': 'No face detected in live image'}, status=400)

        match_found = False
        for live_face in live_faces:
            live_shape = predictor(live_image, live_face)
            live_descriptor = np.array(face_rec_model.compute_face_descriptor(live_image, live_shape))

            distances = [np.linalg.norm(ref_descriptor - live_descriptor) for ref_descriptor in ref_descriptors]
            min_distance = min(distances)
            if min_distance < 0.4:  # Adjust the threshold as needed
                match_found = True
                break

        if match_found:
            return JsonResponse({'message': 'Match Found!'})
        else:
            return JsonResponse({'message': 'No Match'})
    return JsonResponse({'error': 'Invalid request method'}, status=400)
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class Transition : MonoBehaviour
{

	private Vector3 positionInitial;
	private Quaternion rotationInitial;
	private Camera cameraComponent;
	private RaycastHit hitInfo;
	private RenderTexture currentRender;
	private RenderTexture renderTexture;

	void Start ()
	{
		positionInitial = transform.position;
		rotationInitial = transform.rotation;
		cameraComponent = GetComponent<Camera>();
		renderTexture = new RenderTexture(Screen.width, Screen.height, 16, RenderTextureFormat.ARGB32);
	}
	
	void Update ()
	{
		if (Input.GetMouseButtonDown(0)) {
			Ray ray = cameraComponent.ScreenPointToRay(Input.mousePosition);
			if (Physics.Raycast(ray, out hitInfo)) {
				StartTransition(hitInfo.transform.position, hitInfo.transform.rotation);
			}
		}

		if (Input.GetKeyDown(KeyCode.Space) && transform.position != positionInitial) {
			StartTransition(positionInitial, rotationInitial);
		}
	}

	void OnRenderImage (RenderTexture src, RenderTexture dest)
	{
		Graphics.Blit(src, dest);
		currentRender = dest;
	}

	public void StartTransition (Vector3 position, Quaternion rotation)
	{
		transform.position = position;
		transform.rotation = rotation;

		Graphics.Blit(currentRender, renderTexture);
	}
}

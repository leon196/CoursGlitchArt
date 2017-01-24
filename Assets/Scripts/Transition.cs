using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class Transition : MonoBehaviour
{
	public Shader filter;
	public float transitionDelay = 1f;

	private bool isInTransition = false;
	private float transitionStart;

	private Vector3 positionInitial;
	private Quaternion rotationInitial;
	private Camera cameraComponent;
	private RaycastHit hitInfo;
	private RenderTexture currentRender;
	private RenderTexture renderTexture;
	private Material filterMaterial;

	void Start ()
	{
		positionInitial = transform.position;
		rotationInitial = transform.rotation;

		cameraComponent = GetComponent<Camera>();
		renderTexture = new RenderTexture(Screen.width, Screen.height, 16, RenderTextureFormat.ARGB32);
		filterMaterial = new Material(filter);
	}
	
	void Update ()
	{
		if (Input.GetMouseButtonDown(0))
		{
			Ray ray = cameraComponent.ScreenPointToRay(Input.mousePosition);
			if (Physics.Raycast(ray, out hitInfo))
			{
				StartTransition(hitInfo.transform.position, hitInfo.transform.rotation);
			}
		}

		if (Input.GetKeyDown(KeyCode.Space) && transform.position != positionInitial)
		{
			StartTransition(positionInitial, rotationInitial);
		}

		float ratio = Mathf.Clamp01((Time.time - transitionStart) / transitionDelay);
		filterMaterial.SetFloat("_TransitionRatio", ratio);
		filterMaterial.SetTexture("_TransitionTexture", renderTexture);

		if (isInTransition && ratio == 1f) {
			isInTransition = false;
		}
	}

	void OnRenderImage (RenderTexture src, RenderTexture dest)
	{
		Graphics.Blit(src, dest, filterMaterial);
		currentRender = dest;
	}

	public void StartTransition (Vector3 position, Quaternion rotation)
	{
		if (isInTransition == false)
		{
			isInTransition = true;
			transitionStart = Time.time;

			transform.position = position;
			transform.rotation = rotation;

			Graphics.Blit(currentRender, renderTexture);
		}
	}
}

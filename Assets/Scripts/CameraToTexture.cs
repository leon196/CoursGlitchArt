using UnityEngine;
using System.Collections;

public class CameraToTexture : MonoBehaviour
{
	public string textureName = "_CameraTexture";
	RenderTexture renderTexture;
	
	void Awake ()
	{
		renderTexture = new RenderTexture(Screen.width, Screen.height, 24);
		renderTexture.Create();
		GetComponent<Camera>().targetTexture = renderTexture;
	}

	void Update ()
	{
		Shader.SetGlobalTexture(textureName, renderTexture);
	}
}
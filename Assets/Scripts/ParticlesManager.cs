using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticlesManager : MonoBehaviour
{
	public Shader shaderParticle;
	public Shader shaderPosition;

	[Header("Particle")]
	public int particleCount = 100000;
	public float radius = 0.2f;
	public Color color = Color.white;
	public Texture sprite;
	public Transform target;
	
	[Header("Position")]
	public float spawnSpeed = 0.01f;

	[Header("Velocity")]
	[Range(0,1)] public float slowRatio = 0.7f;
	public float speed = 0.1f;
	public Vector3 noiseScale = Vector3.one;
	public Vector3 noiseSpeed = Vector3.one;

	private Material particleMaterial;
	private Material positionMaterial;
	private Mesh[] meshArray;
	private ParticlesPass positionPass;

	void Start ()
	{
		SetupParticleMeshes();
		SetupPass();
		UpdateUniforms();
		positionPass.Update();
	}
	
	void Update ()
	{
		UpdateUniforms();
	}

	private void SetupParticleMeshes ()
	{
		List<GameObject> particles = Utils.CreateParticles(particleCount, transform);
		meshArray = new Mesh[particles.Count];
		particleMaterial = new Material(shaderParticle);
		for (int i = 0; i < particles.Count; ++i) {
			meshArray[i] = particles[i].GetComponent<MeshFilter>().sharedMesh;
			meshArray[i].bounds = new Bounds(Vector3.zero, Vector3.one * 100000f);
			particles[i].GetComponent<Renderer>().sharedMaterial = particleMaterial;
			particles[i].gameObject.layer = gameObject.layer;
		}
		Utils.SetupUV(meshArray);
	}

	private void SetupPass ()
	{
		positionMaterial = new Material(shaderPosition);
		positionPass = new ParticlesPass(positionMaterial, meshArray);
		positionPass.Print(meshArray);
	}

	public void UpdateUniforms ()
	{
		positionMaterial.SetFloat("_Speed", speed);
		positionMaterial.SetFloat("_SlowRatio", slowRatio);
		positionMaterial.SetVector("_NoiseScale", noiseScale);
		positionMaterial.SetVector("_NoiseSpeed", noiseSpeed);
		positionMaterial.SetFloat("_SpawnSpeed", spawnSpeed);
		positionMaterial.SetTexture("_SpawnTexture", positionPass.texture);
		positionMaterial.SetVector("_Target", target.position);

		positionPass.Update();

		particleMaterial.SetTexture("_PositionTexture", positionPass.result);
		particleMaterial.SetFloat("_Radius", radius);
		particleMaterial.SetTexture("_MainTex", sprite);
		particleMaterial.SetColor("_Color", color);
		particleMaterial.SetVector("_Target", target.position);
	}
}
